#!/bin/bash

# taken from https://gitlab.com/postmarketOS/pmaports/-/blob/4818c2c2cdeeedded9472cfa6d715d986b985fc0/main/devicepkg-dev/devicepkg_subpackage_kernel.sh#L26
# MIT licensed https://gitlab.com/postmarketOS/pmaports/-/blob/4818c2c2cdeeedded9472cfa6d715d986b985fc0/main/devicepkg-dev/APKBUILD#L7

# pmbootstrap also replaces
variant="$(echo "$1" | tr '-' '_')"
file="$2"

if ! { [[ -n "$1" ]] && [[ -n "$2" ]] ; } ; then
    echo "USAGE: variant deviceinfo_file"
    exit 1
fi


if ! [[ -e "$file" ]]; then
    echo "ERROR: deviceinfo '$file' doesn't exist"
    exit 1
fi


echo "replacing variant '$variant' in deviceinfo '$file'"

# Iterate over deviceinfo variables that have the variant as suffix
# var looks like: deviceinfo_kernel_cmdline, ...
grep -E "(.+)_$variant=.*" "$file" | \
	sed "s/\(.\+\)_$variant=.*/\1/g" | while IFS= read -r var
do
	if grep -Eq "$var=.*" "$file"; then
		echo "ERROR: variable '$var' already defined without a variant suffix"
		exit 1
	fi

    echo "replacing variable '$var'"

	# Remove the variant suffix from the variable
	sed -i "s/$var\_$variant/$var/g" "$file"

	# Remove the variables with other variant suffixes
	sed -i "/$var\_.*=.*/d" "$file"
done

