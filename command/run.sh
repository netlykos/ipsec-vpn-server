#!/bin/bash

printf "Starting container at $(date)\n"

export L2TP_NET=${VPN_L2TP_NET:-'192.168.42.0/24'}
export L2TP_LOCAL=${VPN_L2TP_LOCAL:-'192.168.42.1'}
export L2TP_POOL=${VPN_L2TP_POOL:-'192.168.42.10-192.168.42.250'}
export XAUTH_NET=${VPN_XAUTH_NET:-'192.168.43.0/24'}
export XAUTH_POOL=${VPN_XAUTH_POOL:-'192.168.43.10-192.168.43.250'}
export DNS_SRV1=${VPN_DNS_SRV1:-'1.1.1.1'}
export DNS_SRV2=${VPN_DNS_SRV2:-'8.8.8.8'}
export DNS_SRVS="\"$DNS_SRV1 $DNS_SRV2\""
[ -n "$VPN_DNS_SRV1" ] && [ -z "$VPN_DNS_SRV2" ] && export DNS_SRVS="$DNS_SRV1"

APP_BIN_DIR=$(dirname "$0")
${APP_BIN_DIR}/setup.sh
${APP_BIN_DIR}/startup.sh
