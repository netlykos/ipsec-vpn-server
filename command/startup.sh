#!/bin/bash

rm /etc/ipsec.d/*.db > /dev/null 2>&1 
ipsec initnss && sleep 1

rm -f /run/pluto/pluto.pid /var/run/pluto/pluto.pid /var/run/xl2tpd.pid

iptables --table nat --append POSTROUTING --jump MASQUERADE
/sbin/sysctl -e -q -w net.ipv4.conf.all.accept_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.all.send_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.accept_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.send_redirects=0
/sbin/sysctl -e -q -w net.ipv4.ip_forward=1
/sbin/sysctl -e -q -w net.ipv4.conf.all.accept_source_route=0
/sbin/sysctl -e -q -w net.ipv4.conf.all.accept_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.all.send_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.all.rp_filter=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.accept_source_route=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.accept_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.send_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.default.rp_filter=0
/sbin/sysctl -e -q -w net.ipv4.conf.eth0.send_redirects=0
/sbin/sysctl -e -q -w net.ipv4.conf.eth0.rp_filter=0

iptables -I INPUT 1 -p udp --dport 1701 -m policy --dir in --pol none -j DROP
iptables -I INPUT 2 -m conntrack --ctstate INVALID -j DROP
iptables -I INPUT 3 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I INPUT 4 -p udp -m multiport --dports 500,4500 -j ACCEPT
iptables -I INPUT 5 -p udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
iptables -I INPUT 6 -p udp --dport 1701 -j DROP
iptables -I FORWARD 1 -m conntrack --ctstate INVALID -j DROP
iptables -I FORWARD 2 -i eth+ -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD 3 -i ppp+ -o eth+ -j ACCEPT
# iptables -A FORWARD -j DROP

iptables -I FORWARD 4 -i ppp+ -o ppp+ -s "${L2TP_NET}" -d "${L2TP_NET}" -j ACCEPT
# iptables -I FORWARD 4 -i ppp+ -o ppp+ -s "192.168.42.0/24" -d "192.168.42.0/24" -j ACCEPT
iptables -I FORWARD 5 -i eth+ -d "${XAUTH_NET}" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# iptables -I FORWARD 5 -i eth+ -d "192.168.43.0/24" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD 6 -s "${XAUTH_NET}" -o eth+ -j ACCEPT
# iptables -I FORWARD 6 -s "192.168.43.0/24" -o eth+ -j ACCEPT
iptables -t nat -I POSTROUTING -s "${XAUTH_NET}" -o eth+ -m policy --dir out --pol none -j MASQUERADE
# iptables -t nat -I POSTROUTING -s "192.168.43.0/24" -o eth+ -m policy --dir out --pol none -j MASQUERADE
iptables -t nat -I POSTROUTING -s "${L2TP_NET}" -o eth+ -j MASQUERADE
# iptables -t nat -I POSTROUTING -s "192.168.42.0/24" -o eth+ -j MASQUERADE

ipsec pluto --stderrlog --config /etc/ipsec.conf
exec /usr/sbin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf
