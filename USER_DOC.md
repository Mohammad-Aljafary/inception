# Inception — User Documentation

This document explains how to use and manage the Inception stack as an end user or administrator.

---

## 📦 What Services Are Provided?

This project provides a complete web hosting stack with three containerized services:

| Service | Description |
|---------|-------------|
| **NGINX** | Web server that handles HTTPS connections on port 443 with SSL encryption |
| **WordPress** | Content Management System (CMS) for creating and managing your website |
| **MariaDB** | Database server that stores all WordPress content and configuration |

All services run in Docker containers and communicate through a private internal network.

---

## ▶️ Starting and Stopping the Project

### Start the Project

From the project root directory, run:

```bash
make up
```

This command builds all containers and starts them in the background. The first startup may take a few minutes as it downloads and configures all services.

### Stop the Project

```bash
make down
```

This stops all running containers but preserves your data.

### Restart the Project

```bash
make re
```

This stops and rebuilds all containers, useful after configuration changes.

### Check Status

```bash
make ps
```

Displays the status of all containers (running, stopped, etc.).

### View Logs

```bash
make logs
```

Shows real-time logs from all services. Press `Ctrl+C` to exit.

---

## 🌐 Accessing the Website

### Main Website

Open your browser and navigate to:

```
https://malja-fa.42.fr
```

> **Note:** You will see a security warning because the SSL certificate is self-signed. This is expected — click "Advanced" and proceed to the site.

### WordPress Administration Panel

To access the admin dashboard:

1. Go to: `https://malja-fa.42.fr/wp-admin`
2. Log in with your administrator credentials

From the admin panel you can:
- Create and edit posts/pages
- Manage users
- Install themes and plugins
- Configure site settings

---

## 🔐 Locating and Managing Credentials

### Credential Files Location

Sensitive credentials are stored in the `secrets/` directory:

| File | Purpose |
|------|---------|
| `secrets/credentials.txt` | General credentials |
| `secrets/db_password.txt` | Database user password |
| `secrets/db_root_password.txt` | Database root password |

### Environment Configuration

Non-sensitive configuration is stored in `srcs/.env`:

| Variable | Description |
|----------|-------------|
| `NAME_DATABASE` | Database name (default: `wordpress`) |
| `USERNAME_DATABASE` | Database username |
| `PASSWORD_DATABASE` | Database password |
| `WP_ADMIN_USER` | WordPress admin username |
| `WP_ADMIN_PASSWORD` | WordPress admin password |
| `WP_ADMIN_EMAIL` | WordPress admin email |
| `WP_URL` | Site URL |

### Changing Credentials

1. Update the relevant file in `secrets/` or `srcs/.env`
2. Restart the project: `make re`

> ⚠️ **Important:** Changing database credentials after initial setup may require manual database updates or a fresh installation.

---

## ✅ Checking That Services Are Running Correctly

### Quick Status Check

```bash
make ps
```

All three containers should show status `Up`:
- `mariadb`
- `wordpress`
- `nginx`

### Detailed Health Checks

**1. Check if the website loads:**
```bash
curl -k https://malja-fa.42.fr
```
You should see HTML content (not an error).

**2. Check container logs for errors:**
```bash
make logs
```
Look for any `ERROR` or `FATAL` messages.

**3. Verify individual containers:**
```bash
docker exec mariadb mysqladmin ping
docker exec wordpress php -v
docker exec nginx nginx -t
```

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| "Connection refused" | Ensure containers are running with `make ps` |
| "502 Bad Gateway" | WordPress container may still be starting; wait and refresh |
| "Certificate error" | Accept the self-signed certificate in your browser |
| Database connection error | Check that MariaDB is running and credentials match |

### Viewing Individual Service Logs

```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

---

## 📞 Need Help?

- Check the logs first: `make logs`
- Ensure all containers are running: `make ps`
- Try restarting: `make re`
- Refer to [README.md](README.md) for additional documentation
