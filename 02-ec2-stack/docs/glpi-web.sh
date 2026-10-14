#!/bin/bash
echo "Aguardando conectividade com a internet..."
# Tenta resolver o mirror do Debian por até 2 minutos (60 tentativas * 2 segundos)
for i in {1..60}; do
    if curl -sI https://debian.org > /dev/null; then
        echo "Internet detectada com sucesso!"
        break
    fi
    echo "Rede ainda indisponível, tentando novamente em 2 segundos... (Tentativa $i/60)"
    sleep 2
done

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade

apt-get install -y \
  nginx \
  curl \
  ca-certificates \
  tar \
  php \
  php-cli \
  php-fpm \
  php-bcmath \
  php-bz2 \
  php-curl \
  php-gd \
  php-intl \
  php-ldap \
  php-mbstring \
  php-mysql \
  php-opcache \
  php-xml \
  php-zip \
  php-apcu

timedatectl set-timezone America/Sao_Paulo

systemctl enable --now nginx

PHP_FPM_SERVICE=$(systemctl list-unit-files \
  --type=service \
  --no-legend \
  'php*-fpm.service' |
  awk 'NR==1 {print $1}')

systemctl enable --now "${PHP_FPM_SERVICE}"

GLPI_VERSION=$(curl -fsSL \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/glpi-project/glpi/releases/latest |
  sed -nE 's/.*"tag_name":[[:space:]]*"([^"]+)".*/\1/p' |
  head -n 1)

GLPI_URL="https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"

cd /var/www

curl -fL \
  "${GLPI_URL}" \
  -o "glpi-${GLPI_VERSION}.tgz"

tar -xzf "glpi-${GLPI_VERSION}.tgz"

rm -f "glpi-${GLPI_VERSION}.tgz"

mkdir -p \
  /etc/glpi \
  /var/lib/glpi \
  /var/log/glpi

cat > /var/www/glpi/inc/downstream.php <<'EOF'
<?php

define('GLPI_CONFIG_DIR', '/etc/glpi/');

if (file_exists(GLPI_CONFIG_DIR . 'local_define.php')) {
    require_once GLPI_CONFIG_DIR . 'local_define.php';
}
EOF

mv /var/www/glpi/config /etc/glpi
mv /var/www/glpi/files /var/lib/glpi

cat > /etc/glpi/local_define.php <<'EOF'
<?php

define('GLPI_VAR_DIR', '/var/lib/glpi');
define('GLPI_DOC_DIR', GLPI_VAR_DIR);
define('GLPI_CACHE_DIR', GLPI_VAR_DIR . '/_cache');
define('GLPI_CRON_DIR', GLPI_VAR_DIR . '/_cron');
define('GLPI_GRAPH_DIR', GLPI_VAR_DIR . '/_graphs');
define('GLPI_LOCAL_I18N_DIR', GLPI_VAR_DIR . '/_locales');
define('GLPI_LOCK_DIR', GLPI_VAR_DIR . '/_lock');
define('GLPI_PICTURE_DIR', GLPI_VAR_DIR . '/_pictures');
define('GLPI_PLUGIN_DOC_DIR', GLPI_VAR_DIR . '/_plugins');
define('GLPI_RSS_DIR', GLPI_VAR_DIR . '/_rss');
define('GLPI_SESSION_DIR', GLPI_VAR_DIR . '/_sessions');
define('GLPI_TMP_DIR', GLPI_VAR_DIR . '/_tmp');
define('GLPI_UPLOAD_DIR', GLPI_VAR_DIR . '/_uploads');
define('GLPI_INVENTORY_DIR', GLPI_VAR_DIR . '/_inventories');
define('GLPI_THEMES_DIR', GLPI_VAR_DIR . '/_themes');
define('GLPI_LOG_DIR', '/var/log/glpi');
EOF

chown -R root:root /var/www/glpi

chown -R www-data:www-data \
  /etc/glpi \
  /var/lib/glpi \
  /var/log/glpi

chown -R www-data:www-data \
  /var/www/glpi/marketplace

find /var/www/glpi -type f -exec chmod 0644 {} \;
find /var/www/glpi -type d -exec chmod 0755 {} \;

find /etc/glpi -type f -exec chmod 0644 {} \;
find /etc/glpi -type d -exec chmod 0755 {} \;

find /var/lib/glpi -type f -exec chmod 0644 {} \;
find /var/lib/glpi -type d -exec chmod 0755 {} \;

find /var/log/glpi -type f -exec chmod 0644 {} \;
find /var/log/glpi -type d -exec chmod 0755 {} \;

PHP_FPM_SOCKET=$(find /run/php \
  -maxdepth 1 \
  -type s \
  -name 'php*-fpm.sock' \
  -print \
  -quit)

cat > /etc/nginx/sites-available/glpi <<EOF
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/glpi/public;

    index index.php;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ ^/index\.php$ {
        include fastcgi_params;

        fastcgi_split_path_info ^(.+\.php)(/.*)\$;

        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$document_root;

        fastcgi_pass unix:${PHP_FPM_SOCKET};
    }

    location ~ /\. {
        deny all;
    }
}
EOF

ln -sf \
  /etc/nginx/sites-available/glpi \
  /etc/nginx/sites-enabled/glpi

rm -f /etc/nginx/sites-enabled/default

systemctl restart nginx