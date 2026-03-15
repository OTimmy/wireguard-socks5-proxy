FROM alpine:3.23.3

ARG WIREGUARD_TOOLS_VERSION=1.0.20250521-r1
ARG DANTE_VERSION=1.4.4-r0

RUN apk add --no-cache \
    bash \
    openresolv \
    iptables \
    ip6tables \
    iproute2 \
    curl \
    wireguard-tools=${WIREGUARD_TOOLS_VERSION} \
    dante-server=${DANTE_VERSION} \
 && echo 'Checking wg-quick for src_valid_mark patch target...' \
 && grep -Fq '[[ $proto == -4 ]] && cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1' /usr/bin/wg-quick \
 && echo 'Patching wg-quick src_valid_mark guard...' \
 && sed -i 's|\[\[ $proto == -4 ]] && cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) -ne 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick

COPY init /init
COPY sockd.conf /etc/sockd.conf
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /healthcheck.sh /init

EXPOSE 1080

ENV LOCAL_NETWORK=192.168.1.0/24

ENTRYPOINT ["/init"]