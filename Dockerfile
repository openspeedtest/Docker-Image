# By OpenSpeedTest
# Dockerfile for https://hub.docker.com/r/openspeedtest/latest
FROM nginxinc/nginx-unprivileged:stable-alpine

LABEL maintainer "OpenSpeedTest.com <support@OpenSpeedTest.com>"

ENV CONFIG=/etc/nginx/conf.d/OpenSpeedTest-Server.conf

COPY /files/OpenSpeedTest-Server.conf ${CONFIG}
COPY /files/entrypoint.sh /entrypoint.sh
RUN rm /etc/nginx/nginx.conf
COPY /files/nginx.conf /etc/nginx/
COPY /files/www/ /usr/share/nginx/html/
COPY /files/nginx.crt /etc/ssl/
COPY /files/nginx.key /etc/ssl/



USER root

RUN rm -rf /etc/nginx/conf.d/default.conf \
	&& chown -R nginx /usr/share/nginx/html/ \
	&& chmod 755 /usr/share/nginx/html/downloading \
	&& chmod 755 /usr/share/nginx/html/upload \
	&& chown nginx ${CONFIG} \
	&& chmod 400 ${CONFIG} \
	&& chown nginx /etc/nginx/nginx.conf \
	&& chmod 400 /etc/nginx/nginx.conf \
	&& chmod +x /entrypoint.sh

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/* 
RUN update-ca-certificates

USER 101

EXPOSE 3000 3001

CMD ["/entrypoint.sh"]
