#!/bin/sh

# check wg0  is up
if [ $(wg show | grep -c "latest handshake") -eq 0 ]; then
  echo "Health check failed: wg0 is not connected."
  exit 1
fi

WG_IP=$(curl --max-time 5 --interface wg0 ifconfig.me) 

PROXY_IP=$(curl --max-time 5 socks5://localhost:1080 ifconfig.me)


if [ -z "$WG_IP" ] || [ -z "$PROXY_IP" ]; then
  echo "Health check failed: wg_ip or proxy_ip timed out."
  exit 1
fi

# Compare the IP addresses
if [ "$WG_IP" = "$PROXY_IP" ]; then
  echo "Health check passed: WG IP and External IP match."
  exit 0
else
  echo "Health check failed: WG IP and External IP do not match."
  exit 1
fi