
# 🧱 oldadmin/openwga

A Docker image for [OpenWGA](https://www.openwga.com), ready to run on Debian Bookworm with OpenJDK 17.  
Easy to use – even without a reverse proxy.

👉 GitHub Repository: [github.com/oldadmin/openwga-docker](https://github.com/oldadmin/openwga-docker)  
📦 Docker Hub: [hub.docker.com/r/oldadmin/openwga](https://hub.docker.com/r/oldadmin/openwga)

## 📦 Includes

- OpenWGA 7.11 CE
- OpenJDK 17
- MySQL/MariaDB Connector
- UTF-8 + German locale
- Configurable entrypoint script

## 🚀 Quick Start with Docker Compose

```yaml
services:
  openwga_database:
    image: mariadb:10.6
    container_name: mariadb-openwga
    restart: always
    volumes:
      - databases:/var/lib/mysql
    environment:
      MARIADB_ROOT_PASSWORD_HASH: TOPSECRET
      MARIADB_USER: WGA_User
      MARIADB_PASSWORD_HASH: WGA_User_Secret_HASH

  openwga:
    image: oldadmin/openwga:7.11.9-jdk17
    container_name: openwga
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - openwga:/var/lib/openwga
      - config:/etc/openwga/
    depends_on:
      - openwga_database

volumes:
  openwga:
  config:
  databases:
```

> 🔎 After startup, OpenWGA will be available at [http://localhost:8080](http://localhost:8080)  
> 🔐 Admin interface: [http://localhost:8080/plugin-admin](http://localhost:8080/plugin-admin)  
> ✉️ Login credentials:
> - **Username**: `admin`
> - **Password**: `wga`

💡 You should change the default password after first login.

## ⚙️ Build Info

This image is based on `debian:bookworm` and includes:
- OpenJDK 17
- OpenWGA 7.11 CE
- MariaDB/MySQL connector

Port 8080 is exposed and mapped to the host system via Compose.

## 👤 UID/GID Mapping – Two Options

By default, the container runs as the internal user `openwga` with UID/GID `10100`.  
If your host user has a different UID/GID (e.g. 1000), you may run into permission issues with mounted volumes.

To fix this, the container supports **runtime UID/GID mapping** via environment variables.

### ✅ Option 1: Set UID/GID at Runtime (Recommended)

Use the `environment:` section in your `docker-compose.yml`:

```yaml
services:
  openwga:
    image: oldadmin/openwga:7.11.9-jdk17
    environment:
      OPENWGA_UID: 1000   # Your host user ID
      OPENWGA_GID: 1000   # Your host group ID
    volumes:
      - ./openwga:/var/lib/openwga
```

The container will automatically adapt its internal `openwga` user to match your local UID/GID.  
This ensures file ownership on mounted volumes matches your user.

### 🛠 Option 2: Apply UID/GID During Image Build

If you want the image to always use specific UID/GID values, you can pass them during build:

```yaml
services:
  openwga:
    image: oldadmin/openwga:7.11.9-jdk17   
    build:
      context: .
      args:
        OPENWGA_UID: 1000
        OPENWGA_GID: 1000
```

This permanently builds the image with the specified UID/GID.  
Note: You only need this if you **build the image yourself locally**.

> 💡 You can also combine both `build:` and `environment:` to cover both use cases.

The entrypoint script automatically adjusts the internal user accordingly.

## 🛠 Entrypoint

The image uses a custom `entrypoint.sh` to start OpenWGA and optionally perform initial setup.  
You can modify and rebuild it as needed.

Key features:
- Dynamically matches UID/GID from volume mount
- JDBC driver gets copied to the correct path
- Tomcat is started via `gosu` to drop privileges

## 🧯 To Do

- Add healthcheck
- Expand documentation
- Optional: HTTPS support via Compose with `traefik` or `nginx`
- ...

---

## 🙌 Built with ❤️ by `oldadmin`

Feedback, issues or pull requests are welcome!  
👉 [https://github.com/oldadmin/openwga-docker](https://github.com/oldadmin/openwga-docker)
