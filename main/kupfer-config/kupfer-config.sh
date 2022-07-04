#!/bin/bash

config_dir="/etc/kupfer"

main() {
    if [[ -z "$1" ]] ; then
        (echo "ERROR: No verb specified!";
        echoverbs) >&2
        exit 1
    fi
    while [[ -n "$1" ]]; do
        case "$1" in
    	apply)
            verb="$1"
            ;;
    	disable)
            verb="$1"
            ;;
        --config-dir)
            config_dir="$2"
            shift
            ;;
    	*)
            (echo "ERROR: unknown argument '${1}'";
    		echoverbs) >&2
            exit 1
            ;;
        esac
        shift
    done

    if ! [ -e "$config_dir" ] ; then
        echo "ERROR: config folder $config_dir doesn't exist! bailing out!" >&2
        exit 1
    fi

    parse_files
    # $enables_list and $disables_list are now set
    case "$verb" in
    disable)
        (echo "$enables_list"; echo "$disables_list") | sort -u | xargs systemctl preset
        ;;
    apply)
        echo "enabling: $(echo "$enables_list" | tr '\n' ' ')!"
        echo "$enables_list" | xargs systemctl enable
        echo "disabling: $(echo "$disables_list" | tr '\n' ' ')!"
        echo "$disables_list" | xargs systemctl disable
        ;;
    *)
        echo "unknown verb, how did you even get here?" >&2
        exit 1
        ;;
    esac
}

echoverbs() {
    echo "Verbs supported: apply, reset"
}

parse_files() {
    systemd_dir="${config_dir}/systemd"
    parse_vendor_files
    parse_user_files
    combine_lists
}

compare_lists() {
    comm -12 <(echo "$user_enables_list") <(echo "$user_disables_list")
}

grepfile() { grep -v -x -f "$@"; }

combine_lists() {
    export user_ignores_list="$(printsorted "${user_ignores[@]}")"
    export user_enables_list="$(printsorted "${user_enables[@]}" | grepfile <(echo "$user_ignores_list") )"
    export user_disables_list="$(printsorted "${user_disables[@]}" | grepfile <(echo "$user_ignores_list") )"

    compare_lists | (while IFS= read -r warn; do
        echo "WARNING: user-overrides request both enabling and disabling item $warn" >&2
    done)

    export vendor_enables_list="$(printsorted "${vendor_enables}" | grepfile <(echo "${user_ignores_list}"; echo "${user_disables_list}"))"
    export vendor_disables_list="$(printsorted "${vendor_disables}" | grepfile <(echo "${user_ignores_list}"; echo "${user_enables_list}"))"

    export enables_list="$( (echo "$vendor_enables_list"; echo "$user_enables_list") | sort -u )"
    export disables_list="$( (echo "$vendor_disables_list"; echo "$user_disables_list") | sort -u )"
}



parse_vendor_files() {
    parse_file "${systemd_dir}"/*.txt
    export vendor_enables=("$file_enables")
    export vendor_disables=("$file_disables")
}

parse_user_files() {
    parse_file "${systemd_dir}"/override.d/*.txt
    export user_enables=("$file_enables")
    export user_disables=("$file_disables")
    export user_ignores=("$file_ignores")
}

parse_file() {
    export file_enables=()
    export file_disables=()
    export file_ignores=()
    while IFS= read -r line ; do
        disable="$(echo "$line" | get_disabled)"
        enable="$(echo "$line" | get_enabled)"
        ignore="$(echo "$line" | get_ignored)"
        if [[ -n "$disable" ]]; then
            file_disables+=("$disable")
        elif [[ -n "$ignore" ]]; then
            file_ignore+=("$ignore")
        elif [[ -n "$enable" ]]; then
            file_enables+=("$enable")
        fi
    done < <(grep -v '^ *#' "$@")
}

printlns() { for i in "$@"; do echo "$i"; done }

printsorted() { printlns "$@" | sort -u; }

start_regex='^[ ]*'
main_regex='[ ]*([0-9a-zA-Z_.@: \\-]+)([ ]*#[ ]*.*)?$/\1/gp'

get_enabled() {
    sed -n -E "s/${start_regex}${main_regex}" "$@"
}

get_disabled() {
    sed -n -E "s/${start_regex}"'[\!]'"${main_regex}" "$@"
}

get_ignored() {
    sed -n -E "s/${start_regex}[/]${main_regex}" "$@"
}

main "$@"
