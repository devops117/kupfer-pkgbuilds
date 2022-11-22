
find_pkgbuild_dirs() {
    git ls-files -z '*/*/PKGBUILD' | xargs -0 dirname -z | xargs -0 -I{} echo '{}/'
}

echoerr() {
    if [ -t 1 ] || [ "$FORCE_COLOR" = "1" ]; then
        echo -e "\033[0;31m${*}\033[0m"
    else
        echo -e "$*"
    fi
}
