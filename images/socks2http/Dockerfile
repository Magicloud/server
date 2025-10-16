FROM alpine
RUN sed -n '/\/main/ s,/[^/]*/main,/edge/testing,p' /etc/apk/repositories >> /etc/apk/repositories
RUN apk add --no-cache polipo
COPY socks2http.sh /socks2http.sh
ENTRYPOINT ["/socks2http.sh"]
