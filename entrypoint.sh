#!/bin/bash
set -e

echo "[Entrypoint] Starte Setup für OpenWGA..."

# Verzeichnisse, die als Volume gemountet sein könnten
VOLUME_PATH="/var/lib/openwga"
CONFIG_PATH="/etc/openwga"

# UID/GID von gemountetem Volume übernehmen
HOST_UID=${OPENWGA_UID:-$(stat -c "%u" "$VOLUME_PATH")}
HOST_GID=${OPENWGA_GID:-$(stat -c "%g" "$VOLUME_PATH")}

# Falls unterschiedlich zur Standard-UID (10123), anpassen
if [ "$HOST_UID" != "$(id -u openwga)" ]; then
    echo "[Entrypoint] Passe openwga UID:GID auf $HOST_UID:$HOST_GID an..."
    usermod -u "$HOST_UID" openwga
    groupmod -g "$HOST_GID" openwga
    chown -R openwga:openwga "$VOLUME_PATH"
    chown -R openwga:openwga "$CONFIG_PATH"
fi

# JDBC-Treiber kopieren
CONNECTOR_SOURCE="/usr/share/java/mysql-connector-j-8.3.0.jar"
CONNECTOR_TARGET="/var/lib/openwga/tomcat/lib/mysql-connector-java.jar"

echo "[Entrypoint] JDBC-Treiber kopieren: $CONNECTOR_SOURCE → $CONNECTOR_TARGET"
mkdir -p /var/lib/openwga/tomcat/lib
cp -f "$CONNECTOR_SOURCE" "$CONNECTOR_TARGET"
chown openwga:openwga "$CONNECTOR_TARGET"

# Starte Tomcat mit gosu als openwga
echo "[Entrypoint] Starte OpenWGA (Tomcat)..."
exec gosu openwga /var/lib/openwga/tomcat/bin/catalina.sh run