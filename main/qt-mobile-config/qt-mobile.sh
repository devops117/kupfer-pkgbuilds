#!/bin/sh

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
fi

export QT_QUICK_CONTROLS_MOBILE=true
