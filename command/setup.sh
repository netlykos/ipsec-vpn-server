#!/bin/bash

for file in \
  /etc/xl2tpd/xl2tpd.conf \
  /etc/ppp/options.xl2tpd \
  /etc/ipsec.conf \
  /etc/ipsec.d/ipsec.secrets
do
  printf "Expanding contents of file ${file} - "
  envsubst < ${file} > ${file}.t && mv ${file}.t ${file}
  printf "Done!\n"
done

# This needs to be done in setup.sh, for some reason it doesn't work when setup in run.sh
# Clear out /etc/ppp/chap-secrets if there was something in there
# Convert CHAP_ACCOUNTS into an associative array called ACCOUNTS, because we can't reference
# CHAP_ACCOUNTS as an associative array for some reason, I think it's because it's not declared
# as an associative array (declare -A CHAP_ACCOUNTS)
T_ACCOUNTS=$(env | grep CHAP_ACCOUNTS | sed 's/CHAP_ACCOUNTS//' | tr -s '\n' ' ')
declare -A ACCOUNTS
eval ACCOUNTS=( ${T_ACCOUNTS})
export ACCOUNTS
# for key in "${!ACCOUNTS[@]}"; do printf "CHAP_ACCOUNT [${key}:${ACCOUNTS[${key}]}]\n"; done

> /etc/ppp/chap-secrets
> /etc/ipsec.d/passwd
for key in "${!ACCOUNTS[@]}"
do 
  VPN_PASSWORD_ENC=$(openssl passwd -1 "${ACCOUNTS[$key]}")
  printf "${key} * ${ACCOUNTS[$key]} *\n" >> /etc/ppp/chap-secrets
  printf "${key}:${VPN_PASSWORD_ENC}:xauth-psk\n" >> /etc/ipsec.d/passwd
done
printf "Completed configuration of $(echo ${!ACCOUNTS[@]} | wc -l) accounts in file(s) /etc/ppp/chap-secrets /etc/ipsec.d/passwd\n"
