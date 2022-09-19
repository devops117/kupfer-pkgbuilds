#!/usr/bin/env python3
from __future__ import annotations
from argparse import ArgumentParser

import logging
import os
import subprocess

PROG_NAME = 'kupfer-config'
DEFAULT_CONF_DIR = '/etc/kupfer'
SYSTEMD_DIR = 'systemd'
OVERRIDE_DIR = 'overrides.d'

argparser = ArgumentParser(prog=PROG_NAME)
argparser.add_argument('-c', '--config-dir', help='The config dir to look in', default=DEFAULT_CONF_DIR)
argparser.add_argument('-d', '--dry-run', help='Only print what would be done', action='store_true')
argparser.add_argument('-v', '--verbose', help='Print debug logs', action='store_true')
argparser.set_defaults(func=argparser.print_help)
cmdparsers = argparser.add_subparsers()
cmdparser_apply = cmdparsers.add_parser('apply', help='apply systemd service states')
cmdparser_disable = cmdparsers.add_parser('disable', help='revert systemd service states to presets')


class SystemdUnits:
    enable: set[str]
    disable: set[str]
    ignore: set[str]

    def __init__(self, enable: set[str] = set(), disable: set[str] = set(), ignore: set[str] = set()):
        self.enable = set()
        self.disable = set()
        self.ignore = set()
        self.enable.update(enable)
        self.disable.update(disable)
        self.ignore.update(ignore)

    def update(self, u: SystemdUnits):
        self.enable.update(u.enable)
        self.disable.update(u.disable)
        self.ignore.update(u.ignore)


def parse_file(path: str) -> SystemdUnits:
    with open(path, 'r') as f:
        lines = f.readlines()
    result = SystemdUnits()
    for i, line in enumerate(lines):
        line = line.strip()
        # skip comment lines
        if line.startswith('#'):
            continue
        # strip off trailing in-line comments and associated whitespace
        line = line.split('#')[0].strip()
        # skip empty lines
        if not line:
            continue
        if '.' not in line:
            newline = f'{line}.service'
            filename = f'{os.path.basename(os.path.dirname(path))}/{os.path.basename(path)}'
            logging.debug(f'{filename}: line {i}: asumming "{newline}" for "{line}"')
            line = newline
        if line.startswith('!'):
            result.disable.add(line[1:].strip())
        elif line.startswith('/'):
            result.ignore.add(line[1:].strip())
        else:
            result.enable.add(line)
    return result


def parse_dir(directory: str) -> SystemdUnits:
    if not os.path.exists(os.path.realpath(directory)):
        raise Exception(f'Directory "{directory}" doesn\'t exist')
    result = SystemdUnits()
    for p in os.listdir(directory):
        path = os.path.join(directory, p)
        if not os.path.isfile(os.path.realpath(path)):
            continue
        if not p.endswith('.txt'):
            logging.warning(f'skipping file "{p}" in {directory}: name does not end with ".txt"')
            continue
        result.update(parse_file(path))
    return result


def parse_vendor_dir(config_dir: str) -> SystemdUnits:
    return parse_dir(os.path.join(config_dir, SYSTEMD_DIR))


def parse_overrides_dir(config_dir: str) -> SystemdUnits:
    d = os.path.join(config_dir, SYSTEMD_DIR, OVERRIDE_DIR)
    if not os.path.isdir(os.path.realpath(d)):
        return SystemdUnits()
    return parse_dir(d)


def parse_all(config_dir: str) -> SystemdUnits:
    vendor = parse_vendor_dir(config_dir)
    overrides = parse_overrides_dir(config_dir)
    conflicts = overrides.enable.intersection(overrides.disable.union(overrides.ignore))
    if conflicts:
        logging.warning(f'Overrides directory both enables and disables or ignores services: {" ".join(conflicts)}')
    if vendor.ignore:
        logging.warning(f'Vendor files specify ignores (lines starting with "/").\n'
                        'This is either a bug in kupfer packages or a user modification.\n'
                        f'Hint: modifications should go in {config_dir}/{SYSTEMD_DIR}/{OVERRIDE_DIR}')
    result = SystemdUnits()
    result.update(vendor)
    result.ignore = overrides.ignore.copy()
    for u in vendor.disable:
        result.enable.discard(u)
        result.disable.add(u)
    for u in overrides.enable:
        result.disable.discard(u)
        result.enable.add(u)
    for u in overrides.disable:
        result.enable.discard(u)
        result.disable.add(u)
    for u in result.ignore:
        for s in [result.disable, result.enable]:
            s.discard(u)
    assert not result.ignore.intersection(result.enable.union(result.disable))
    return result


def run_systemd_cmd(action: str = 'enable', units: list[str] = [], dry_run: bool = False):
    logging.info(f'systemctl: {action} units: {" ".join(units)}')
    cmd = ['systemctl', action, *units]
    if dry_run:
        print(f"Would run: `{' '.join(cmd)}`")
        return
    res = subprocess.run(cmd)
    if res.returncode:
        raise Exception(f'Failed to {action} systemd units: {units}')
    return res


def cmd_apply():
    units = parse_all(parsed.config_dir)
    for action, action_units in [('enable', units.enable), ('disable', units.disable)]:
        if action_units:
            run_systemd_cmd(action, action_units, dry_run=parsed.dry_run)


def cmd_disable():
    units = parse_all(parsed.config_dir)
    run_systemd_cmd('preset', units.enable.union(units.disable), dry_run=parsed.dry_run)


cmdparser_apply.set_defaults(func=cmd_apply)
cmdparser_disable.set_defaults(func=cmd_disable)


if __name__ == '__main__':
    parsed = argparser.parse_args()
    logging.basicConfig(level=logging.DEBUG if parsed.verbose else logging.INFO)
    parsed.func()
