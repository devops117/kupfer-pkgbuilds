#!/bin/sh

# Firefox uses xinput by default, this setting
# makes it pick the libinput backend which enables proper touchscreen support
# and smooth scrolling + gestures even touchpads
if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ "$XDG_SESSION_TYPE" = "x11" ] ; then
	export MOZ_USE_XINPUT2=2
fi
