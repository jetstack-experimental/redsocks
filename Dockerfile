FROM alpine:3.5

RUN apk update && \
    apk add bash libevent && \
    rm -rf /var/cache/apk/*

ENV DEV_PACKAGES alpine-sdk curl libevent-dev linux-headers

ENV REDSOCKS_VERSION 0.5

RUN apk update && \
    apk add -s ${DEV_PACKAGES} > /tmp/temp-packages && \
    apk add ${DEV_PACKAGES} && \
    curl -sL -o /tmp/redsocks.tar.gz https://github.com/darkk/redsocks/archive/release-0.5.tar.gz && \
    cd /tmp && \
    tar xfz /tmp/redsocks.tar.gz && \
    cd /tmp/redsocks-release-0.5 && \
    make && \
    mv redsocks /usr/bin && \
    rm -rf /tmp/redsocks-release-0.5 && \
    cat /tmp/temp-packages | head -n -1 | cut -d " " -f 3 | xargs apk del && \
    rm -rf /tmp/redsocks.tar.gz /tmp/temp-packages && \
    rm -rf /var/cache/apk/*

RUN redsocks -v

RUN addgroup -g 180 -S redsocks
RUN adduser -u 180 -S redsocks redsocks

ADD redsocks.conf /tmp/
ADD run.sh /run.sh
CMD ["/bin/bash", "/run.sh"]
