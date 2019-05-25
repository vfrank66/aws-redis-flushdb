FROM alpine

ARG redis_engine_version 
ARG address 
ARG port 


ENV REDIS_VERSION=${redis_engine_version}
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz

ENV REDIS_ADDRESS=${address}
ENV REDIS_PORT=${port}

RUN apk update && apk upgrade \
    && apk add --update --no-cache --virtual build-deps gcc make linux-headers musl-dev tar \
    && echo "${REDIS_DOWNLOAD_URL}" \
    && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis install redis-cli /usr/bin \
    && rm -r /usr/src/redis \
    && apk del build-deps \
    && rm -rf /var/cache/apk/*

# stunnel - proxy designed to add TLS encryption function to existing clients and programs
RUN apk add stunnel -y 
RUN echo $'fips = no \n\
setuid = root \n\
setgid = root \n\
pid = /var/run/stunnel.pid \n\
debug = 7 \n\
options = NO_SSLv3 \n\
[redis-cli] \n\
client = yes \n\
accept = 127.0.0.1:6379 \n\
connect = ${address}:${port}' > /etc/stunnel/redis-cli.conf

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh
RUN set -x && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["sh", "docker-entrypoint.sh"]
