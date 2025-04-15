#!/bin/bash
set -e

echo "[Entrypoint] Start setup for OpenWGA..."

# Define volume paths which may be mounted from the host
VOLUME_PATH="/var/lib/openwga"
CONFIG_PATH="/etc/openwga"

# Detect UID/GID from mounted volume or use environment defaults
HOST_UID=${OPENWGA_UID:-$(stat -c "%u" "$VOLUME_PATH")}
HOST_GID=${OPENWGA_GID:-$(stat -c "%g" "$VOLUME_PATH")}

# If UID/GID differs from default, update the user/group and fix ownership
if [ "$HOST_UID" != "$(id -u openwga)" ]; then
    echo "[Entrypoint] Adjusting UID:GID of user 'openwga' to $HOST_UID:$HOST_GID..."
    usermod -u "$HOST_UID" openwga
    groupmod -g "$HOST_GID" openwga
    chown -R openwga:openwga "$VOLUME_PATH"
    chown -R openwga:openwga "$CONFIG_PATH"
fi

# Prepare JDBC connector for MySQL/MariaDB
CONNECTOR_SOURCE="/usr/share/java/mysql-connector-j-8.3.0.jar"
CONNECTOR_TARGET="/var/lib/openwga/tomcat/lib/mysql-connector-java.jar"

echo "[Entrypoint] Copy JDBC driver: $CONNECTOR_SOURCE → $CONNECTOR_TARGET"
mkdir -p /var/lib/openwga/tomcat/lib
cp -f "$CONNECTOR_SOURCE" "$CONNECTOR_TARGET"
chown openwga:openwga "$CONNECTOR_TARGET"

# Start OpenWGA (Tomcat) as non-root user
echo "[Entrypoint] Starting OpenWGA (Tomcat)..."
exec gosu openwga /var/lib/openwga/tomcat/bin/catalina.sh run
