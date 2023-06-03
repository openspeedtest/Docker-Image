#!/bin/sh

ip a | egrep -q 'inet6 '
if [[ $? -ne 0 ]]; then
  # IPv6 not enabled
  sed -i '/listen \[::\]:300/d' ${CONFIG}
fi

ip a | egrep -q 'inet '
if [[ $? -ne 0 ]]; then
  # IPv4 not enabled
  sed -i '/listen 300/d' ${CONFIG}
fi

exec nginx -g 'daemon off;'
