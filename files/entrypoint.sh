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


if [ "$CHANGE_CONTAINER_PORTS" = True ]; then
    if [ "$HTTP_PORT" ]; then
        sed -i "s/3000/${HTTP_PORT}/g" ${CONFIG}
        if [ $? -eq 0 ]; then
        echo "Changed HTTP container port to " ${HTTP_PORT}
        else
        echo "Failed to change HTTP container port to " ${HTTP_PORT}
        fi        
         
    fi

    if [ "$HTTPS_PORT" ]; then
        sed -i "s/3001/${HTTPS_PORT}/g" ${CONFIG}
        if [ $? -eq 0 ]; then
        echo "Changed HTTPS container port to " ${HTTPS_PORT}
        else
        echo "Failed to change HTTPS container port to " ${HTTPS_PORT}
        fi    

    fi
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

if [ "$SET_SERVER_NAME" ]; then
      SERVER_NAME='<h1 style="display: inline;color: #7c888d; font-size: 22px;font-family: Roboto-Medium, Roboto;font-weight: 500;">'${SET_SERVER_NAME}'</h1>'
      if ! grep -q "$SERVER_NAME" "$INDEX_HTML"; then
      sed -i -e '/<body>/a\'$'\n'"$SERVER_NAME" ${INDEX_HTML}
      fi
fi

if [ "$ALLOW_ONLY" ]; then

allow_only=${ALLOW_ONLY}

IFS=';' domains=$(echo "$allow_only" | tr ';' '\n')

map_config="map \$http_origin \$allowed_origin {
    default 0;
"
while IFS= read -r line; do
    escaped_domain=$(echo "$line" | sed 's/\./\\./g')
    map_config="$map_config    \"~^https?://(www\.)?($escaped_domain)\$\" 1;
"
done < <(printf '%s\n' "$domains")

map_config="$map_config}"

nginx_conf_path="/etc/nginx/nginx.conf"
pattern="map \$http_origin \$allowed_origin {"
nginx_block="if (\$allowed_origin = 0) { return 444; }"

if grep -q "$pattern" "$nginx_conf_path"; then
    echo "Map config found! nginx.conf not modified"
else
    while IFS= read -r line; do
sed -i '/^\s*http\s*{/ {
    :a;
    N;
    /\s*}\s*$/!ba;
    s|\(}\)|'"$line"'\n\1|
}' "$nginx_conf_path"
    done < <(printf '%s\n' "$map_config")
        if [ $? -eq 0 ]; then
    echo "Map config added to nginx.conf"
            if grep -q "$nginx_block" "$CONFIG"; then
            echo "Block Config found! OpenSpeedTest-Server.conf not modified"
            else
            echo "Adding Block Config to OpenSpeedTest-Server.conf"
                    sed -i '/location \/ {/ {
                        a\
                '"$nginx_block"'
                    }' "$CONFIG"

                    sed -i '/location ~\* \^.+\\.(?:css|cur|js|jpe?g|gif|htc|ico|png|html|xml|otf|ttf|eot|woff|woff2|svg)\$ {/ {
                        a\
                '"$nginx_block"'
                    }' "$CONFIG"
                    if [ $? -eq 0 ]; then
                    echo "Added Block to OpenSpeedTest-Server.conf"
                    else
                    echo "Failed to Add Block to OpenSpeedTest-Server.conf"
                    fi
            fi
    

        else
    echo "Failed to add map config to nginx.conf"
fi
fi

fi


if [ "$DOMAIN_NAME" ]; then
sed -i "/\bYOURDOMAIN\b/c\ server_name _ localhost ${DOMAIN_NAME};" "${CONFIG}"
fi

nginx -g 'daemon off;' & sleep 5

if [ "$ENABLE_LETSENCRYPT" = True ] && [ "$DOMAIN_NAME" ] && [ "$USER_EMAIL" ]; then
 fullchain_path="/var/log/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"
  certbot certonly -n --webroot --webroot-path /usr/share/nginx/html --no-redirect --agree-tos --email "$USER_EMAIL" -d "$DOMAIN_NAME" --config-dir /var/log/letsencrypt/ --work-dir /var/log/letsencrypt/work --logs-dir /var/log/letsencrypt/log 

  if [ $? -eq 0 ]; then

      if [ -f "$fullchain_path" ]; then
      sed -i "/\bssl_certificate\b/c\ssl_certificate \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/fullchain.pem;" "${CONFIG}"
      sed -i "/\bssl_certificate_key\b/c\ssl_certificate_key \/var\/log\/letsencrypt\/live\/${DOMAIN_NAME}\/privkey.pem;" "${CONFIG}"
      nginx -s reload
      echo "Let's Encrypt certificate obtained successfully."
      random_minute=$(shuf -i 0-59 -n 1)
      random_hour=$(shuf -i 0-23 -n 1)
      echo "$random_minute $random_hour * * * /renew.sh > /proc/1/fd/1 2>&1" > /etc/crontabs/nginx
      else
      echo "letsencrypt Certificates Not Found!"
      fi
  else
    echo "Failed to obtain Let's Encrypt certificate."
  fi

  crond -b -l 5
fi


tail -f /dev/null
