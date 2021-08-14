#!/bin/bash
set -e
packages=()
FROM=${1:-"@~1"}
TO=${2:-"@"}
for file in $(git diff --name-only "$FROM" "$TO"); do
    if [[ "$file" == "main/"* ]]; then
        packages+=("$(echo "$file" | awk -F "/" '{print $1"/"$2}')")
    elif [[ "$file" == "device/"* ]]; then
        packages+=("$(echo "$file" | awk -F "/" '{print $1"/"$2"/"$3}')")
    fi
done
for package in $(echo "${packages[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '); do
    echo "$package"
done
