FROM arm32v6/alpine:latest
LABEL maintainer="Adi B <16106232+netlykos@users.noreply.github.com>"

ENV APP_BASE_DIR /opt/apps/ipsec-vpn-server

WORKDIR ${APP_BASE_DIR}
COPY ./bin ${APP_BASE_DIR}/bin

RUN apk add --no-cache iptables xl2tpd xl2tpd-openrc ppp openswan openrc 
# Need the following for associative arrays
RUN apk add --no-cache bash
RUN chmod a+x ${APP_BASE_DIR}/bin/*

EXPOSE 500/udp 4500/udp
