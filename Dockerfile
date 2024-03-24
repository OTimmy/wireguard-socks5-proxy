FROM alpine:latest as dantebuild

ENV DANTE_FILE_NAME dante-1.4.3
ENV DANTE_URL https://www.inet.no/dante/files/$DANTE_FILE_NAME.tar.gz
ENV DANTE_SHA256 418a065fe1a4b8ace8fbf77c2da269a98f376e7115902e76cda7e741e4846a5d
ENV ac_cv_func_sched_setscheduler no

RUN apk update && apk add --no-cache \
    build-base \
    curl &&\
    curl -s $DANTE_URL -o $DANTE_FILE_NAME.tar.gz &&\
    tar -xvf $DANTE_FILE_NAME.tar.gz &&\
    cd $DANTE_FILE_NAME &&\
    ./configure &&\
    make &&\
    make install

FROM alpine:latest as wireguardbuild
ENV WIREGUARD_TOOLS_REPO https://git.zx2c4.com/wireguard-tools

COPY src_valid_mark_check_before_syscall_set_patch.git /patch.git

RUN apk add --no-cache \
    build-base \
    linux-headers \
    curl \
    git &&\
    git clone $WIREGUARD_TOOLS_REPO &&\
    cd wireguard-tools &&\
    git apply /patch.git &&\
    make WITH_WGQUICK=yes -C src install

FROM alpine:latest
RUN apk add --no-cache \
    bash \
    openresolv \
    iptables \
    iproute2 \
    curl

COPY --from=dantebuild /usr/local/sbin/sockd /usr/local/sbin/sockd
COPY --from=wireguardbuild /usr/bin/wg /usr/bin/wg
COPY --from=wireguardbuild /usr/bin/wg-quick /usr/bin/wg-quick

COPY init /init
COPY sockd.conf /etc/sockd.conf
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /healthcheck.sh


EXPOSE 1080
EXPOSE 51820

ENV LOCAL_NETWORK=192.168.1.0/24

ENTRYPOINT ["/init"]