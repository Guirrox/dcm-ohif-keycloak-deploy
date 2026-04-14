
#!/bin/bash

# Colores para una terminal elegante
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# 1. DETECCIÓN DE IP / CONFIGURACIÓN
# Si pasas una IP como argumento (./generate-ssl.sh 10.0.0.5), la usa.
# Si no pasas nada, detecta la IP local automáticamente.
IP_AUTO=$(hostname -I | awk '{print $1}')
DOMAIN="${1:-$IP_AUTO}"

SSL_DIR="./ssl"
DAYS=365
BITS=2048

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🔐 GENERADOR DE CERTIFICADOS SSL AUTO-FIRMADOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

# 2. CREACIÓN DE CARPETA
if [ ! -d "$SSL_DIR" ]; then
    echo -e "${YELLOW}📁 Creando directorio de seguridad: $SSL_DIR${NC}"
    mkdir -p "$SSL_DIR"
fi

# 3. VERIFICAR OPENSSL
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}❌ OpenSSL no encontrado. Instalando...${NC}"
    sudo apt update && sudo apt install -y openssl
fi

echo -e "${BLUE}🌐 Configurando para la IP/Dominio: ${GREEN}$DOMAIN${NC}"

# 4. GENERACIÓN DE CERTIFICADOS
echo -e "${YELLOW}🔑 Generando llave privada y certificado público...${NC}"

# Ejecución de OpenSSL
sudo openssl req -x509 -nodes -days $DAYS -newkey rsa:$BITS \
  -keyout "$SSL_DIR/nginx.key" \
  -out "$SSL_DIR/nginx.crt" \
  -subj "/C=HN/ST=Cortes/L=SPS/O=Medical/OU=IT/CN=$DOMAIN" \
  2>/dev/null

# 5. VERIFICACIÓN Y PERMISOS
if [ $? -eq 0 ] && [ -f "$SSL_DIR/nginx.crt" ]; then
    echo -e "${GREEN}✅ ¡Éxito! Certificados creados correctamente.${NC}"
    
    # Ajustar permisos para que Docker/Nginx no tengan conflictos
    sudo chmod 644 "$SSL_DIR/nginx.crt"
    sudo chmod 600 "$SSL_DIR/nginx.key"
    
    echo ""
    echo -e "${BLUE}📋 Resumen de archivos:${NC}"
    echo -e "  ${GREEN}✓${NC} Certificado: $SSL_DIR/nginx.crt"
    echo -e "  ${GREEN}✓${NC} Llave privada: $SSL_DIR/nginx.key"
    echo ""
    echo -e "${YELLOW}🔍 Detalles del certificado:${NC}"
    openssl x509 -in "$SSL_DIR/nginx.crt" -noout -subject -dates
else
    echo -e "${RED}❌ Error crítico al generar los certificados.${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Sistema listo para usar en: ${NC} https://$DOMAIN"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
