.SILENT:

%.utf8/LC_NAME:
	if [[ "$*" != "POSIX" ]] && [[ "$*" != "cns"* ]] && [[ "$*" != "i18n"* ]] && [[ "$*" != "iso"* ]] && [[ "$*" != "translit"* ]]; then \
		echo "Preparing $*"; \
		localedef -f UTF-8 -i $* ./$*.utf8; \
	fi
