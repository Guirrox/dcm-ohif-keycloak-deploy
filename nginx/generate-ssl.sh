#!/bin/bash
set -e

mkdir -p ssl

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout ssl/nginx.key \
  -out ssl/nginx.crt \
  -subj "/C=HN/ST=Cortes/L=SanPedroSula/O=PACS/OU=IT/CN=10.100.100.5"

echo "Certificados creados:"
echo "  nginx/ssl/nginx.crt"
echo "  nginx/ssl/nginx.key"
