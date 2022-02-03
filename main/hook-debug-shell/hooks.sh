#!/usr/bin/ash

run_hook() {
    export IP=172.16.42.1

    mount -t proc -o nodev,noexec,nosuid proc /proc || echo "Couldn't mount /proc"
    mount -t configfs -o nodev,noexec,nosuid configfs /sys/kernel/config || echo "Couldn't mount /sys/kernel/config"
    mkdir -p /dev/pts
    mount -t devpts devpts /dev/pts || echo "Couldn't mount /dev/pts"

    /usr/bin/usb-tethering
    start_udhcpd

    telnetd -b "$IP:23" -l sh
    while ! [[ -e /CONTINUE_BOOT ]] ; do
        sleep 1
    done
}

start_udhcpd() {
    # Only run once
    [ -e /etc/udhcpd.conf ] && return

    # Skip if disabled
    # shellcheck disable=SC2154
    if [ "$deviceinfo_disable_dhcpd" = "true" ]; then
        echo "NOTE: start of dhcpd is disabled (deviceinfo_disable_dhcpd)"
        touch /etc/udhcpcd.conf
        return
    fi

    echo "Starting udhcpd"
    # Get usb interface
    INTERFACE=""
    ifconfig rndis0 "$IP" 2>/dev/null && INTERFACE=rndis0
    if [ -z $INTERFACE ]; then
        ifconfig usb0 "$IP" 2>/dev/null && INTERFACE=usb0
    fi
    if [ -z $INTERFACE ]; then
        ifconfig eth0 "$IP" 2>/dev/null && INTERFACE=eth0
    fi

    if [ -z $INTERFACE ]; then
        echo "  Could not find an interface to run a dhcp server on"
        echo "  Interfaces:"
        ip link
        return
    fi

    echo "  Using interface $INTERFACE"

    # Create /etc/udhcpd.conf
    {
        echo "start 172.16.42.2"
        echo "end 172.16.42.2"
        echo "auto_time 0"
        echo "decline_time 0"
        echo "conflict_time 0"
        echo "lease_file /var/udhcpd.leases"
        echo "interface $INTERFACE"
        echo "option subnet 255.255.255.0"
    } >/etc/udhcpd.conf

    echo "  Start the dhcpcd daemon (forks into background)"
    udhcpd
}

run_cleanuphook() {
    for daemon in telnetd udhcpd; do
        busybox pkill "$daemon"
    done
}
