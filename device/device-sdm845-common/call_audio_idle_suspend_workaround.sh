#!/bin/sh

interface=org.freedesktop.ModemManager1.Call
member=StateChanged

dbus-monitor --system "type='signal',interface='$interface',member='$member'" |
while read -r line ; do
	state=$(echo "$line" | grep -w "int32" | awk '{print $2}')
	if [ -n "$state" ]; then
		# Call State is based on https://www.freedesktop.org/software/ModemManager/doc/latest/ModemManager/ModemManager-Flags-and-Enumerations.html#MMCallState
		if [ "$state" -eq '0' ]; then
			echo "Call Started"

			# Unload module-suspend-on-idle when call begins
			pactl unload-module module-suspend-on-idle
		fi

		if [ "$state" -eq '7' ]; then
			echo "Call Ended"

			# Reload module-suspend-on-idle after call ends
			pactl load-module module-suspend-on-idle
		fi
	fi
done
