FROM alpine:3.5

RUN apk update && \
    apk add redsocks bash iptables && \
    rm -rf /var/cache/apk/*

RUN addgroup -g 180 -S redsocks
RUN adduser -u 180 -S redsocks redsocks

ADD redsocks.conf /tmp/
ADD run.sh /run.sh
CMD ["/bin/bash", "/run.sh"]
