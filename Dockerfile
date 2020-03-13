FROM arm32v6/alpine:latest
LABEL maintainer="Adi B <adib@netlykos.org>"

WORKDIR /opt/apps/ipsec-vpn-server

RUN apk add --no-cache iptables xl2tpd xl2tpd-openrc ppp openswan

EXPOSE 500/udp 4500/udp
