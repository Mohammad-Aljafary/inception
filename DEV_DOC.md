# Inception — Developer Documentation

This document describes how to set up, build, and manage the Inception project from a development perspective.

---

## 🛠️ Setting Up the Environment from Scratch

### Prerequisites

Ensure the following are installed on your system:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+ or `docker compose` plugin)
- **Root/sudo access** (for creating directories and modifying `/etc/hosts`)
- **Port 443 available** (for NGINX HTTPS)

Verify installation:
```bash
docker --version
docker compose version
```

### Step 1: Create Data Directories

The project uses bind mounts for persistent storage. Create the required directories:

```bash
sudo mkdir -p /home/malja-fa/data/mariadb
sudo mkdir -p /home/malja-fa/data/wordpress
sudo chown -R $USER:$USER /home/malja-fa/data
```

> **Note:** These paths are hardcoded in `srcs/docker-compose.yml`. Modify them if needed for your environment.

### Step 2: Configure Secrets

Create the secrets directory (if not exists) and populate the secret files:

```bash
mkdir -p secrets

# Database user password
echo "your_secure_db_password" > secrets/db_password.txt

# Database root password
echo "your_secure_root_password" > secrets/db_root_password.txt

# Additional credentials
echo "your_credentials" > secrets/credentials.txt
```

> ⚠️ **Security:** Never commit secrets to version control. Ensure `secrets/` is in `.gitignore`.

### Step 3: Create Environment File

Create `srcs/.env` with your configuration:

```bash
cat > srcs/.env <<EOF
NAME_DATABASE=wordpress
USERNAME_DATABASE=wp_user
PASSWORD_DATABASE=your_secure_db_password
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure_admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_URL=https://malja-fa.42.fr
WP_USER=author_user
WP_USER_EMAIL=author@example.com
WP_USER_PASSWORD=author_password
EOF
```

### Step 4: Configure Hostname

Add the domain to your hosts file:

```bash
echo "127.0.0.1 malja-fa.42.fr" | sudo tee -a /etc/hosts
```

---

## 🏗️ Building and Launching the Project

### Using the Makefile

The [Makefile](Makefile) provides convenient commands:

| Command | Description |
|---------|-------------|
| `make up` | Build images and start all containers in detached mode |
| `make down` | Stop and remove all containers |
| `make re` | Rebuild and restart all containers |
| `make logs` | Follow logs from all containers |
| `make ps` | Show status of all containers |

### Direct Docker Compose Commands

For more granular control, use Docker Compose directly:

```bash
# Build without starting
docker compose -f srcs/docker-compose.yml build

# Start with build
docker compose -f srcs/docker-compose.yml up -d --build

# Stop without removing volumes
docker compose -f srcs/docker-compose.yml stop

# Remove containers, networks (preserves volumes)
docker compose -f srcs/docker-compose.yml down

# Remove everything including volumes (DESTRUCTIVE)
docker compose -f srcs/docker-compose.yml down -v
```

---

## 🐳 Managing Containers and Volumes

### Container Management

**List running containers:**
```bash
docker ps
```

**Access a container shell:**
```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

**Inspect container details:**
```bash
docker inspect mariadb
docker inspect wordpress
docker inspect nginx
```

**View container logs:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
docker logs -f nginx  # Follow logs in real-time
```

### Volume Management

**List volumes:**
```bash
docker volume ls
```

**Inspect volumes:**
```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

**Remove volumes (DESTRUCTIVE):**
```bash
docker volume rm srcs_mariadb_data srcs_wordpress_data
```

### Network Management

**List networks:**
```bash
docker network ls
```

**Inspect the project network:**
```bash
docker network inspect srcs_inception_network
```

---

## 💾 Data Storage and Persistence

### Where Data Is Stored

| Data Type | Container Path | Host Path |
|-----------|---------------|-----------|
| MariaDB database | `/var/lib/mysql` | `/home/malja-fa/data/mariadb` |
| WordPress files | `/var/www/html` | `/home/malja-fa/data/wordpress` |

### How Persistence Works

The project uses **bind mounts** defined in [srcs/docker-compose.yml](srcs/docker-compose.yml):

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/malja-fa/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/malja-fa/data/wordpress
```

This means:
- Data survives container restarts and rebuilds
- You can directly access/backup files on the host
- Removing containers does **not** delete data
- You must manually delete host directories to reset data

### Backup and Restore

**Backup MariaDB database:**
```bash
docker exec mariadb mysqldump -u root wordpress > backup.sql
```

**Restore MariaDB database:**
```bash
docker exec -i mariadb mysql -u root wordpress < backup.sql
```

**Backup WordPress files:**
```bash
sudo tar -czvf wordpress_backup.tar.gz /home/malja-fa/data/wordpress
```

### Complete Reset

To completely reset the project and start fresh:

```bash
# Stop containers
make down

# Remove data directories
sudo rm -rf /home/malja-fa/data/mariadb/*
sudo rm -rf /home/malja-fa/data/wordpress/*

# Rebuild
make up
```

---

## 📁 Project Structure

```
inception/
├── Makefile                    # Build commands
├── README.md                   # Project overview
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # Developer documentation (this file)
├── secrets/                    # Sensitive credentials (not in git)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                    # Environment variables
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/default.conf
        └── wordpress/
            ├── Dockerfile
            └── tools/wordpress_setup.sh
```

---

## 🔧 Service Configuration Details

### MariaDB

- **Dockerfile:** [srcs/requirements/mariadb/Dockerfile](srcs/requirements/mariadb/Dockerfile)
- **Config:** [srcs/requirements/mariadb/conf/my.cnf](srcs/requirements/mariadb/conf/my.cnf)
- **Entrypoint:** [srcs/requirements/mariadb/tools/entrypoint.sh](srcs/requirements/mariadb/tools/entrypoint.sh)
- **Port:** 3306 (internal only)

### WordPress

- **Dockerfile:** [srcs/requirements/wordpress/Dockerfile](srcs/requirements/wordpress/Dockerfile)
- **Setup script:** [srcs/requirements/wordpress/tools/wordpress_setup.sh](srcs/requirements/wordpress/tools/wordpress_setup.sh)
- **Port:** 9000 (PHP-FPM, internal only)

### NGINX

- **Dockerfile:** [srcs/requirements/nginx/Dockerfile](srcs/requirements/nginx/Dockerfile)
- **Config:** [srcs/requirements/nginx/conf/default.conf](srcs/requirements/nginx/conf/default.conf)
- **Port:** 443 (exposed to host)
- **SSL:** Self-signed certificates generated during build

---

## 🐛 Debugging Tips

### Container Won't Start

1. Check logs: `docker logs <container_name>`
2. Verify environment variables are set
3. Ensure data directories exist with correct permissions

### Database Connection Issues

```bash
# Test from wordpress container
docker exec -it wordpress bash
mariadb -h mariadb -u wp_user -p
```

### PHP/WordPress Issues

```bash
# Check PHP-FPM status
docker exec wordpress ps aux | grep php

# Test PHP
docker exec wordpress php -v
```

### NGINX Issues

```bash
# Test configuration
docker exec nginx nginx -t

# Check if upstream (wordpress) is reachable
docker exec nginx ping wordpress
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [NGINX Documentation](https://nginx.org/en/docs/)
