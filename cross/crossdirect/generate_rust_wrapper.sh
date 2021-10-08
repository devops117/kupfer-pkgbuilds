#!/bin/sh
# modified from https://gitlab.com/postmarketOS/pmaports/-/blob/master/cross/crossdirect/rustc.sh

arch="$1"

cat << EOF
#!/bin/sh
if ! LD_LIBRARY_PATH=/native/lib:/native/usr/lib \\
	/native/usr/bin/rustc \\
		-Clinker=/native/usr/lib/crossdirect/rust-qemu-linker \\
		--target="$arch" \\
		--sysroot=/usr \\
		"\$@"; then
	echo "---" >&2
	echo "WARNING: crossdirect: cross compiling with rustc failed, trying"\
		"again with rustc + qemu" >&2
	echo "---" >&2
	# Usually the crossdirect approach works; however, when passing
	# --extern to rustc with a dynamic library (.so), it fails with an
	# error like 'can't find crate for \`serde_derive\` (although the crate
	# does exist). I think it fails to parse the metadata of the so file
	# for some reason. We probably need to adjust rustc's
	# librustc_metadata/locator.rs or something (and upstream that
	# change!), but I've spent enough time on this already. Let's simply
	# fall back to compiling in qemu in the very few cases where this is
	# necessary.
	/usr/bin/rustc "\$@"
fi
EOF
