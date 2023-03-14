This directory is for enabling/disabling systemd units.

## WARNING

The files in this directory and `user/` are placed there by kupfer packages, do not edit them directly.
Place your customizations in `overrides.d/` and `user/overrides.d/` respectively.

Please see overrides.d/example.lst for more information on the file format.

## User directory

The files in `user/` are for systemd user services and can be applied with `kupfer-config --user apply`.
Inside `user/`, the files are also managed by packaging.
Please use `user/overrides.d/` for customization.
