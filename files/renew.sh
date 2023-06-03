#!/bin/sh


fullchain_path="/var/log/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"

if [ "$ENABLE_SSL" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then

certbot renew --force-renewal
    if [ $? -eq 0 ]; then
        echo "certbot renew --force-renewal Executed."
        if [ -f "$fullchain_path" ]; then
        nginx -s reload
        else
        echo "letsencrypt Certificates Not Found!"
        fi
    else
        echo "certbot renew --force-renewal Failed."
    fi

fi