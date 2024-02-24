# WireGuard-SOCKS5 Proxy

## Description

This Docker image allows the routing of application traffic through a VPN by utilizing a SOCKS5 proxy. It's ideal for connecting multiple individual applications to be routed trough one sinlge wireguard client.

## Docker Compose File

To deploy the service, use the following `docker-compose.yml` configuration:

```yaml
version: '3'
services:
  proxy:
    image: wireguard-socks5-proxy:latest
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    ports:
      - 1080:1080
      - 51820:51820
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    volumes:
      - ./wg0.conf:/etc/wireguard/wg0.conf
    restart: on-failure
    healthcheck:                               #Optional
      test: ["CMD", "/healthcheck.sh"]
      interval: 15s
      timeout: 5s
      retries: 1
      start_period: 5s
```

Ensure your wg0.conf WireGuard configuration file is placed in the same directory as this Docker Compose file. Start the service with the command: docker-compose up -d.

## Health Check Script
The container features a health check script that verifies both the VPN's operational status and the correct routing of the SOCKS5 proxy's network traffic through the VPN.
