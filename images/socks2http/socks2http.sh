#!/bin/sh

SOCKS_HOST="${1}"
SOCKS_PORT="${2}"
SOCKS_VER="${3}"

mkdir -p /etc/polipo
cat << EOF > /etc/polipo/config
proxyAddress = "0.0.0.0"
socksParentProxy = "${SOCKS_HOST}:${SOCKS_PORT}"
socksProxyType = ${SOCKS_VER}
EOF

polipo
