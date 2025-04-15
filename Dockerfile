FROM debian:bookworm

# Systemabhängigkeiten installieren
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    gnupg \
    tar \
    lsb-release \
    locales \
    gosu \
    ca-certificates \
    openjdk-17-jdk \
    && echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8
ENV TZ=Europe/Berlin

ARG OPENWGA_UID=10100
ARG OPENWGA_GID=10100

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN echo "deb http://download.openwga.com/deb trusty main" > /etc/apt/sources.list.d/openwga.list \
    && wget -qO - http://download.openwga.com/deb/pub.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/openwga.gpg \
    && apt-get update \
    && apt-get install -y openwga7.11-ce \
    && wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_8.3.0-1debian11_all.deb -O /tmp/mysql-connector.deb && \
    apt-get install -y /tmp/mysql-connector.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/mysql-connector.deb \
    && usermod -u ${OPENWGA_UID} openwga \
    && groupmod -g ${OPENWGA_GID} openwga \
    && chown -R ${OPENWGA_UID}:${OPENWGA_GID} /var/lib/openwga /etc/openwga \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Arbeitsverzeichnis
WORKDIR /home/openwga

# Default-Umgebungsvariablen (auch für Laufzeit änderbar)
ENV OPENWGA_UID=${OPENWGA_UID}
ENV OPENWGA_GID=${OPENWGA_GID}
# Benutzerwechsel
# USER openwga

# Portfreigabe (für Tomcat)
EXPOSE 8080

# Startpunkt
ENTRYPOINT ["/entrypoint.sh"]
