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

set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  upgrade

apt-get install -y mariadb-server mariadb-client

sed -i \
  's/^[[:space:]]*bind-address[[:space:]]*=.*/bind-address = 0.0.0.0/' \
  /etc/mysql/mariadb.conf.d/50-server.cnf


systemctl enable mariadb
systemctl start mariadb

mariadb-secure-installation <<EOF

n
Y
Y
Y
Y
EOF

# Configuração do banco GLPI
mysql <<'SQL'

CREATE DATABASE IF NOT EXISTS glpi
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'glpi'@'%'
  IDENTIFIED BY 'Amarelo0!';

ALTER USER 'glpi'@'%'
  IDENTIFIED BY 'Amarelo0!';

GRANT ALL PRIVILEGES ON glpi.* 
  TO 'glpi'@'%';

GRANT SELECT ON mysql.time_zone_name
  TO 'glpi'@'%';

FLUSH PRIVILEGES;

SQL

systemctl restart mariadb
