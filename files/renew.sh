#!/bin/sh


fullchain_path="/var/log/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"

if [ "$ENABLE_LETSENCRYPT" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then

certbot certonly -n --webroot --webroot-path /usr/share/nginx/html --no-redirect --agree-tos --email "$USER_EMAIL" -d "$DOMAIN_NAME" --config-dir /var/log/letsencrypt/ --work-dir /var/log/letsencrypt/work --logs-dir /var/log/letsencrypt/log
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
