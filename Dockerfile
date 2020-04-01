FROM arm32v6/alpine:latest
LABEL maintainer="Adi B <16106232+netlykos@users.noreply.github.com>"

ENV APP_BASE_DIR /opt/app/ipsec-vpn-server

RUN apk add --no-cache openrc libreswan xl2tpd ppp gettext openssl bash
RUN mkdir -p /var/run/pluto /var/run/xl2tpd /run/openrc /etc/ipsec.d /etc/xl2tpd /etc/ppp

WORKDIR ${APP_BASE_DIR}
COPY ./command ${APP_BASE_DIR}/bin
COPY ./config/etc/ipsec.conf /etc
COPY ./config/etc/ipsec.d/ipsec.secrets /etc/ipsec.d
COPY ./config/etc/xl2tpd/xl2tpd.conf /etc/xl2tpd
COPY ./config/etc/ppp/options.xl2tpd /etc/ppp

RUN touch /var/run/xl2tpd/l2tp-control /run/openrc/softlevel
RUN chmod a+x ${APP_BASE_DIR}/bin/*

VOLUME ["/lib/modules"]

CMD ["./bin/run.sh"]

EXPOSE 500/udp 4500/udp
