#!/bin/bash

WLAN_IFACE=wlp1s0f0u4
CONF_FILE=/etc/wifi-connect.conf

if [ "$EUID" -ne 0 ]; then
    echo "Please use sudo or root account!"
    exit 69
fi

if [ ! -f $CONF_FILE ]
then
    echo "Configuration file not found."
    exit 68
fi

# Konek ke jaringan Wi-Fi menggunakan wpa_supplicant
wpa_supplicant -i$WLAN_IFACE -c$CONF_FILE -B

# Dapatkan alamat IP dari dhcp server
dhclient $WLAN_IFACE
