#!/bin/bash

DOMAIN_ARRAY=()
IFS=',' read -a DOMAIN_ARRAY <<< "$DOMAIN_NAME"
fullchain_path="/var/log/letsencrypt/live/${DOMAIN_ARRAY[0]}/fullchain.pem"

if [ "$ENABLE_LETSENCRYPT" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then

certbot certonly -n --webroot --webroot-path /usr/share/nginx/html --no-redirect --agree-tos --email "$USER_EMAIL" --expand ${DOMAIN_ARRAY[@]/#/ -d } --config-dir /var/log/letsencrypt/ --work-dir /var/log/letsencrypt/work --logs-dir /var/log/letsencrypt/log
    if [ $? -eq 0 ]; then
        echo "certbot certonly -n... Executed."
        if [ -f "$fullchain_path" ]; then
        nginx -s reload
        else
        echo "letsencrypt Certificates Not Found!"
        fi
    else
        echo "certbot certonly -n... Failed."
    fi

fi
