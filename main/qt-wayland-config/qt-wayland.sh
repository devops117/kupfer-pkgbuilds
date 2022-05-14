#!/bin/sh

# Qt applications run using XWayland by default on GNOME, this setting
# makes it pick the Wayland backend without setting GDK_BACKEND=wayland
# which causes more issues in the GNOME stack.
# 
# QT_QPA_PLATFORM has the option of an XWayland fallback, enabled by default.
# To disable the XWayland fallback, remove "xcb" from the QT_QPA_PLATFORM envvar below.
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	export QT_QPA_PLATFORM="wayland;xcb"
fi
