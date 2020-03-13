#!/bin/sh

echo "HOST_IP=${HOST_IP}"
echo "ROUTER_IP=${ROUTER_IP}"
echo "IPSEC_SHARED_SECRET=${IPSEC_SHARED_SECRET}"
echo "CHAP_ACCOUNTS:"
for key in "${!CHAP_ACCOUNTS[@]}"
do 
  echo "${key}:${CHAP_ACCOUNTS[$key]}"
done

sudo iptables --table nat --append POSTROUTING --jump MASQUERADE
sudo iptables -I INPUT -p UDP --dport 4500 -j ACCEPT
sudo iptables -I INPUT -p UDP --dport 500 -j ACCEPT

for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done 
sysctl -p

cat << EOF_SYSCTL_CONF >> /etc/sysctl.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.ip_forward = 1
EOF_SYSCTL_CONF

# Config IPsec tunnel
# note: Openswan using left & right describe VPN server & clients
cat << EOF_IPSEC_CONF >> /etc/ipsec.conf
version 2.0

config setup
  nat_traversal=yes
  protostack=netkey
  virtual_private=%v4:10.0.0.0/8,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v4:!10.25$
  oe=off

conn L2TP-PSK-NAT
  rightsubnet=vhost:%priv
  also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
  authby=secret
  pfs=no
  auto=add
  keyingtries=3
  # we cannot rekey for %any, let client rekey
  rekey=no
  # Apple iOS doesn't send delete notify so we need dead peer detection to detect vanishing clients
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
  # Set ikelifetime and keylife to same defaults windows has
  ikelifetime=8h
  keylife=1h
  # l2tp-over-ipsec is transport mode
  type=transport
  #
  left=$[HOST_IP]
  #
  # For updated Windows 2000/XP clients,
  # to support old clients as well, use leftprotoport=17/%any
  leftprotoport=17/1701
  # The remote user.
  right=%any
  # Using the magic port of "%any" means "any one single port". This is a work around required for 
  # Apple OSX clients that use a randomly high port.
  rightprotoport=17/%any
  # force all to be nat'ed. because of ios
  forceencaps=yes

# Normally, KLIPS drops all plaintext traffic from IP's it has a crypted
# connection with. With L2TP clients behind NAT, that's not really what
# you want. The connection below allows both l2tp/ipsec and plaintext
# connections from behind the same NAT router.
# The l2tpd use a leftprotoport, so they are more specific and will be used
# first. Then, packets for the host on different ports and protocols (eg ssh)
# will match this passthrough conn.
conn passthrough-for-non-l2tp
  type=passthrough
  left=${HOST_IP}
  leftnexthop=${ROUTER_IP}
  right=0.0.0.0
  rightsubnet=0.0.0.0/0
  auto=route

EOF_IPSEC_CONF
echo "Completed configuration of file /etc/ipsec.conf"

# Add PSK key, protect your key from the bright side of network
cat << EOF_IPSEC_SECRET >> /etc/ipsec.secrets
${HOST_IP} %any : PSK "${IPSEC_SHARED_SECRET}"
EOF_IPSEC_SECRET
echo "Completed configuration of file /etc/ipsec.secrets"

# See https://linux.die.net/man/5/xl2tpd.conf
cat << EOF_XL2TPD_CONF >> /etc/xl2tpd/xl2tpd.conf
[global]
ipsec saref = yes
listen-addr = ${HOST_IP}

[lns default]
ip range = 10.0.5.50-10.0.5.255
local ip = ${HOST_IP}
assign ip = yes
require chap = yes
refuse pap = yes
require authentication = yes
name = linkVPN
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF_XL2TPD_CONF 
echo "Completed configuration of file /etc/xl2tpd/xl2tpd.conf"

# Now work around with ppp, to provide DNS info to L2TP tunnel
cat << EOF_OPTIONS_XL2TPD >> /etc/ppp/options.xl2tpd
ipcp-accept-local
ipcp-accept-remote
ms-dns ${ROUTER_IP}
asyncmap 0
auth
crtscts
lock
idle 1800
mtu 1200
mru 1200
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
nodefaultroute
connect-delay 5000
EOF_OPTIONS_XL2TPD 
echo "Completed configuration of file /etc/ppp/options.xl2tpd"

for key in "${!CHAP_ACCOUNTS[@]}"
do 
  echo "${key} * ${CHAP_ACCOUNTS[$key]} *" >> /etc/ppp/chap-secrets
done
echo "Completed configuration of file /etc/ppp/chap-secrets"
