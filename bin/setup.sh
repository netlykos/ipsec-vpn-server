#!/bin/sh

echo "HOST_IP=${HOST_IP}"
echo $MYPASSWORD
echo $MYUSERNAME
echo $MYGATEWAY
echo $MYSECRET

# Disable ICMP redirect, prevent protocol message redirect
cat <<EOF_SYSCTL_CONF >> /etc/sysctl.conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF_SYSCTL_CONF

# Config IPsec tunnel
# note: Openswan using left & right describe VPN server & clients

cat <<EOF_IPSEC_CONF >>/etc/ipsec.conf
version 2.0

config setup
  nat_traversal=yes
  protostack=netkey
  # Do not use 192.168.0.0/16 for it's using everywhere
  virtual_private=%v4:10.0.0.0/8,%v4:172.16.0.0/12
  oe=off

conn L2TP-PSK-NAT
  rightsubnet=vhost:%priv
  also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
  authby=secret
  pfs=no
  auto=add
  keyingtries=3
  # https://imdjh.github.io/sysadmin/2015/04/19/setup-pptp-with-l2tp-vpn-server-on-wheezy.html
  # has rekey to yes, see man page for more details
  # we cannot rekey for %any, let client rekey (from https://github.com/ritazh/l2tpvpn-docker-pi/blob/master/run.sh)
  rekey=no
  # Apple iOS doesn't send delete notify so we need dead peer detection
  # to detect vanishing clients
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
  # Set ikelifetime and keylife to same defaults windows has
  ikelifetime=8h
  keylife=1h
  # l2tp-over-ipsec is transport mode
  type=transport
  # The VPN server IP
  left=${HOST_IP}
  leftprotoport=17/1701
  # Remote user details
  right=%any
  # Using the magic port of "%any" means "any one single port". This is a work around required for Apple OSX 
  # clients that use a randomly high port.
  rightprotoport=17/%any
  # force all to be nat'ed. because of ios
  forceencaps=yes
  # If your server is within a gateway, you ought to configure leftnexthop to gateway IP
  leftnexthop=%defaultroute

EOF_IPSEC_CONF
