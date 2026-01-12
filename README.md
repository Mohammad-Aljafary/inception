*This project has been created as part of the 42 curriculum by malja-fa.*

# Inception
## Description

Inception is a system administration project focused on service containerization using Docker.

The goal is to containerize the following services:

- **NGINX** — A high-performance web server and reverse proxy
- **WordPress** — A free, open-source Content Management System (CMS) for building websites
- **MariaDB** — An open-source relational database management system (RDBMS), a community-driven fork of MySQL

All services run on **Debian 12** Docker base images and communicate through a dedicated Docker network.

## Project Description

### Docker Architecture

This project uses Docker to containerize each service independently, ensuring isolation, portability, and reproducibility. Each container has its own Dockerfile with custom configurations:

| Service | Purpose | Port |
|---------|---------|------|
| nginx | Reverse proxy with SSL termination | 443 |
| wordpress | PHP-FPM application server | 9000 (internal) |
| mariadb | Database storage | 3306 (internal) |

### Design Choices

- **Debian 12** as base image for stability and security
- **PHP-FPM** for efficient PHP processing
- **Self-signed SSL certificates** for HTTPS encryption
- **WP-CLI** for automated WordPress installation
- **Custom entrypoint scripts** for service initialization


### Comparisons

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|--------|
| Isolation | Full OS isolation | Process-level isolation |
| Resource Usage | Heavy (full OS per VM) | Lightweight (shared kernel) |
| Startup Time | Minutes | Seconds |
| Portability | Limited | High (images are portable) |
| Use Case | Complete OS environments | Microservices, applications |

**Choice:** Docker was chosen for its lightweight nature and fast deployment, ideal for running multiple services on a single host.

#### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| Security | Encrypted, access-controlled | Plain text, visible in processes |
| Storage | External files, vaults | In-memory, config files |
| Best For | Passwords, API keys | Non-sensitive configuration |

**Choice:** This project uses Docker secrets for sensitive data (passwords) and environment variables for non-sensitive configuration.

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|---------------|--------------|
| Isolation | Containers isolated | No network isolation |
| Port Mapping | Required | Direct access |
| Security | Better (controlled exposure) | Less secure |
| Performance | Slight overhead | Native performance |

**Choice:** A custom bridge network (`inception_network`) provides service isolation while allowing inter-container communication.

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| Management | Managed by Docker | Host filesystem |
| Portability | High | Host-dependent |
| Performance | Optimized | Direct filesystem access |
| Backup | Docker commands | Standard file tools |

**Choice:** Bind mounts are used (`/home/malja-fa/data/`) for persistent data storage, allowing direct access to WordPress and MariaDB data.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Root/sudo access
- Port 443 available

### Setup

1. **Create data directories:**
   ```bash
   sudo mkdir -p /home/malja-fa/data/mariadb
   sudo mkdir -p /home/malja-fa/data/wordpress
   ```

2. **Create secrets directory and files:**
   ```bash
   mkdir -p secrets
   echo "your_db_password" > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   echo "your_credentials" > secrets/credentials.txt
   ```

3. **Create environment file** (`srcs/.env`):
   ```env
   NAME_DATABASE=wordpress
   USERNAME_DATABASE=wp_user
   PASSWORD_DATABASE=your_password
   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=admin_password
   WP_ADMIN_EMAIL=admin@example.com
   WP_URL=https://malja-fa.42.fr
   ```

4. **Add hostname to /etc/hosts:**
   ```bash
   echo "127.0.0.1 malja-fa.42.fr" | sudo tee -a /etc/hosts
   ```

### Usage

```bash
# Build and start all services
make up

# View logs
make logs

# Check container status
make ps

# Stop all services
make down

# Rebuild and restart
make re
```

### Access

Open `https://malja-fa.42.fr` in your browser (accept the self-signed certificate warning).

## Resources

### Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [WordPress Installation Guide](https://developer.wordpress.org/advanced-administration/before-install/howto-install/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### Tutorials

- [Docker for Beginners](https://docker-curriculum.com/)
- [Docker Networking Guide](https://docs.docker.com/network/)
- [SSL/TLS with NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI Usage

AI tools (GitHub Copilot) were used in this project for:
- **Debugging:** Identifying issues in shell scripts and Docker configurations
- **Code Review:** Suggesting improvements for entrypoint scripts
- **Research:** Understanding Docker networking and volume concepts
