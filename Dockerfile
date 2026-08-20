# By OpenSpeedTest
# Dockerfile for https://hub.docker.com/r/openspeedtest/latest
FROM nginxinc/nginx-unprivileged:stable-alpine

LABEL maintainer="OpenSpeedTest.com <support@OpenSpeedTest.com>"

ENV ENABLE_LETSENCRYPT=false
ENV DOMAIN_NAME=false
ENV USER_EMAIL=false
ENV CONFIG=/etc/nginx/conf.d/OpenSpeedTest-Server.conf
ENV INDEX_HTML=/usr/share/nginx/html/index.html

ENV CHANGE_CONTAINER_PORTS=false
ENV HTTP_PORT=3000
ENV HTTPS_PORT=3001
ENV SET_USER=101

ARG FILE_SIZE=31457280
ENV FILE_SIZE=${FILE_SIZE}
ARG WITHOUT_LETSENCRYPT=false

COPY /files/OpenSpeedTest-Server.conf ${CONFIG}
COPY /files/entrypoint.sh /entrypoint.sh
COPY /files/renew.sh /renew.sh
RUN rm /etc/nginx/nginx.conf
COPY /files/nginx.conf /etc/nginx/
COPY /files/www/ /usr/share/nginx/html/
COPY /files/nginx.crt /etc/ssl/
COPY /files/nginx.key /etc/ssl/



USER root
VOLUME /var/log/letsencrypt


RUN rm -rf /etc/nginx/conf.d/default.conf \
    && chown -R nginx /usr/share/nginx/html/ \
    && chmod 744 /usr/share/nginx/html/upload \
    && chown nginx ${CONFIG} \
    && chmod 400 ${CONFIG} \
    && chown nginx /etc/nginx/nginx.conf \
    && chmod 400 /etc/nginx/nginx.conf \
    && chmod +x /entrypoint.sh \
	&& chmod +x /renew.sh



RUN mkdir -p /etc/letsencrypt && \
    chown -R nginx /etc/letsencrypt && \
    chmod 775 /etc/letsencrypt

RUN mkdir -p /var/lib/letsencrypt && \
    chown -R nginx /var/lib/letsencrypt && \
    chmod 775 /var/lib/letsencrypt

RUN mkdir -p /var/log/letsencrypt && \
    chown -R nginx /var/log/letsencrypt && \
    chmod 775 /var/log/letsencrypt

RUN mkdir -p /usr/share/nginx/html/.well-known/acme-challenge && \
    chown -R nginx /usr/share/nginx/html/.well-known/acme-challenge && \
    chmod 775 /usr/share/nginx/html/.well-known/acme-challenge

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/* 
RUN update-ca-certificates
RUN if [ "${WITHOUT_LETSENCRYPT}" != "true" ]; then \
        apk add --no-cache certbot certbot-nginx && \
        apk update && apk add --no-cache dcron libcap && \
        chown nginx:nginx /usr/sbin/crond && \
        setcap cap_setgid=ep /usr/sbin/crond && \
        touch /etc/crontabs/nginx && \
        chown -R nginx:nginx /etc/crontabs/nginx; \
    fi

USER ${SET_USER}

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

STOPSIGNAL SIGQUIT

CMD ["/entrypoint.sh"]
