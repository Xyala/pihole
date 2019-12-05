#!/bin/bash

# Share Eth (Pi Lan) with Eth USB device
#
#
# This script is created to work with Raspbian Stretch
# but it can be used with most of the distributions
# by making few changes.
#
# Make sure you have already installed `dnsmasq`
# Please modify the variables according to your need
# Don't forget to change the name of network interface
# Check them with `ifconfig`

ip_address="192.168.2.1"
netmask="255.255.255.0"
dhcp_range_start="192.168.2.2"
dhcp_range_end="192.168.2.100"
dhcp_time="12h"
#eth1 is the Pi USB lan connector
ethUSB="eth1"
#eth is the Pi eth port
eth="eth0"

iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
iptables -A FORWARD -i $eth -o $ethUSB -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ethUSB -o $eth -j ACCEPT

sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

ifconfig $ethUSB $ip_address netmask $netmask

# Remove default route created by dhcpcd
ip route del 0/0 dev $ethUSB &> /dev/null

echo -e "interface=$ethUSB\n\
bind-interfaces\n\
server=127.0.0.1\n\
domain-needed\n\
bogus-priv\n\
dhcp-range=$dhcp_range_start,$dhcp_range_end,$dhcp_time" > /etc/dnsmasq.d/custom-dnsmasq.conf

systemctl restart dnsmasq

while : ; do echo "Idling ... "; sleep 600; done
