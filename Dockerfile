FROM nginx:1.20.0-alpine

COPY nginx-keys/ /tmp/nginx-keys
COPY compile.sh /tmp/compile.sh
RUN chmod +x /tmp/compile.sh && \
    /tmp/compile.sh && \
    rm -rf /tmp/*

COPY entrypoint/ /opt/entrypoint
COPY confs/ /opt/confs
COPY scripts/ /opt/scripts
COPY fail2ban/ /opt/fail2ban
COPY logs/ /opt/logs
COPY lua/ /opt/lua

COPY prepare.sh /tmp/prepare.sh
RUN chmod +x /tmp/prepare.sh && /tmp/prepare.sh && rm -f /tmp/prepare.sh

# fix CVE-2021-20205
RUN apk add "libjpeg-turbo>=2.1.0-r0"

VOLUME /www /http-confs /server-confs /modsec-confs /modsec-crs-confs /cache /pre-server-confs /acme-challenge

EXPOSE 8080/tcp 8443/tcp

USER nginx:nginx

ENTRYPOINT ["/opt/entrypoint/entrypoint.sh"]
