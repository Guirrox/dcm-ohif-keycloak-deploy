#!/bin/bash

# --- Paleta de Colores ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Encabezado Visual ---
clear
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${CYAN}🚀 REDIECH PACS ${NC}       ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Detección de Red
IP_ACTUAL=$(hostname -I | awk '{print $1}')
echo -e "${CYAN}[1/4]${NC} ${YELLOW}📡 Detectando entorno de red...${NC}"
sleep 1
echo -e "      ${BLUE}⮕${NC} IP del Servidor: ${GREEN}$IP_ACTUAL${NC}"
echo ""

# 2. Reemplazo Masivo de IPs
echo -e "${CYAN}[2/4]${NC} ${YELLOW}📝 Sincronizando configuraciones...${NC}"
# Reemplaza cualquier formato de IP por la IP actual del sistema
sudo find . -type f -not -path '*/.*' -not -name 'deploy.sh' -exec sed -i -E "s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/$IP_ACTUAL/g" {} +
echo -e "      ${GREEN}✓${NC} Archivos .js, .yml y .conf actualizados."
echo ""

# 3. Generación de Seguridad SSL (dentro de nginx)
echo -e "${CYAN}[3/4]${NC} ${YELLOW}🔐 Preparando túnel de seguridad SSL...${NC}"

# Verificar si existe el directorio nginx
if [ ! -d "./nginx" ]; then
    echo -e "      ${RED}❌ Error: No existe el directorio ./nginx${NC}"
    exit 1
fi

# Crear directorio ssl dentro de nginx
mkdir -p ./nginx/ssl
echo -e "      ${GREEN}✓${NC} Directorio creado: ${BLUE}./nginx/ssl${NC}"

# Generar certificados directamente (sin script externo)
echo -e "      ${YELLOW}⮕${NC} Generando certificado SSL para ${GREEN}$IP_ACTUAL${NC}..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./nginx/ssl/nginx.key \
    -out ./nginx/ssl/nginx.crt \
    -subj "/C=HN/ST=Cortes/L=SPS/O=Medical/CN=$IP_ACTUAL" \
    2>/dev/null

# Verificar generación de certificados
if [ -f "./nginx/ssl/nginx.crt" ] && [ -f "./nginx/ssl/nginx.key" ]; then
    chmod 644 ./nginx/ssl/nginx.crt
    chmod 600 ./nginx/ssl/nginx.key
    echo -e "      ${GREEN}✓${NC} Certificados generados:"
    echo -e "         ${BLUE}📁${NC} Certificado: ${CYAN}./nginx/ssl/nginx.crt${NC}"
    echo -e "         ${BLUE}🔑${NC} Clave:       ${CYAN}./nginx/ssl/nginx.key${NC}"
else
    echo -e "      ${RED}❌ Error al generar certificados SSL${NC}"
    exit 1
fi
echo ""

# 4. Orquestación Docker
echo -e "${CYAN}[4/4]${NC} ${YELLOW}🐳 Desplegando contenedores Docker...${NC}"
sudo docker compose up -d
echo ""

# --- Panel Final de Acceso ---
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${GREEN}✅ DESPLIEGUE COMPLETADO CON ÉXITO${NC}                          ${BLUE}║${NC}"
echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}🌐 Acceso OHIF:${NC}     https://$IP_ACTUAL             ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}🌐 Acceso DCM4CHEE:${NC}     https://$IP_ACTUAL/dcm4chee-arc/ui2/       ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}🌐 Keycloak Admin:${NC}  https://$IP_ACTUAL/admin        ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo -e "      ${CYAN}📌 Certificados SSL guardados en: ./nginx/ssl/${NC}"
echo -e "      ${CYAN}🔐 Recuerda aceptar el certificado auto-firmado en el navegador.${NC}\n"
