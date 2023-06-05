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

Verify_TXT_path="/usr/share/nginx/html/Verify.txt"

if [ "$VERIFY_OWNERSHIP" ]; then
      if [ -f "$Verify_TXT_path" ]; then
      echo "Verify.txt Found!"
      else
      echo ${VERIFY_OWNERSHIP} > /usr/share/nginx/html/Verify.txt
      echo "Verify.txt Created!"
      fi
fi

if [ "$DOMAIN_NAME" ]; then
sed -i "/\bYOURDOMAIN\b/c\ server_name _ localhost ${DOMAIN_NAME};" "${CONFIG}"
fi

nginx -g 'daemon off;' & sleep 5

if [ "$ENABLE_SSL" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then

fullchain_path="/var/log/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"

certbot certonly -n --webroot --webroot-path /usr/share/nginx/html --no-redirect --agree-tos --email "$USER_EMAIL" -d "$DOMAIN_NAME" --config-dir /var/log/letsencrypt/ --work-dir /var/log/letsencrypt/work --logs-dir /var/log/letsencrypt/log 

  if [ $? -eq 0 ]; then

      if [ -f "$fullchain_path" ]; then
      sed -i "/\bssl_certificate\b/c\ssl_certificate \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/fullchain.pem;" "${CONFIG}"
      sed -i "/\bssl_certificate_key\b/c\ssl_certificate_key \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/privkey.pem;" "${CONFIG}"
      nginx -s reload
      echo "Let's Encrypt certificate obtained successfully."
      echo "039 3 * * * /renew.sh > /proc/1/fd/1 2>&1" > /etc/crontabs/nginx
      else
      echo "letsencrypt Certificates Not Found!"
      fi
  else
    echo "Failed to obtain Let's Encrypt certificate."
  fi
fi

crond -b -l 5

tail -f /dev/null