#!/bin/bash
set -e

echo "Starting MariaDB..."

# Create required directories
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Check required variables
if [ -z "$NAME_DATABASE" ] || [ -z "$USERNAME_DATABASE" ] || [ -z "$PASSWORD_DATABASE" ] || [ -z "$PASSWORD_ROOT_DATABASE" ]; then
    echo "ERROR: Missing environment variables!"
    echo "NAME_DATABASE=$NAME_DATABASE"
    echo "USERNAME_DATABASE=$USERNAME_DATABASE"
    echo "PASSWORD_DATABASE is set: $([ -n "$PASSWORD_DATABASE" ] && echo yes || echo no)"
    echo "PASSWORD_ROOT_DATABASE is set: $([ -n "$PASSWORD_ROOT_DATABASE" ] && echo yes || echo no)"
    exit 1
fi

touch /var/lib/mysql/.mysql_initialized
# Check if database is already initialized (marker file)
FIRST_RUN=false
if [ ! -f "/var/lib/mysql/.mysql_initialized" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    FIRST_RUN=true
    touch /var/lib/mysql/.mysql_initialized
fi
# Start MariaDB server in the background
mysqld --user=mysql --datadir=/var/lib/mysql &
pid=$!

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
for i in {1..30}; do
    if mysqladmin ping --silent 2>/dev/null; then
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

if ! mysqladmin ping --silent 2>/dev/null; then
    echo "MariaDB failed to start!"
    exit 1
fi

echo "MariaDB is running."

# Only run SQL setup on first initialization
if [ "$FIRST_RUN" = true ]; then
    mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASSWORD_ROOT_DATABASE}';
FLUSH PRIVILEGES;
EOF

    echo "Root password set. Creating database and user..."
    mysql -u root -p"${PASSWORD_ROOT_DATABASE}" <<EOF
CREATE DATABASE IF NOT EXISTS ${NAME_DATABASE};
CREATE USER IF NOT EXISTS '${USERNAME_DATABASE}'@'%' IDENTIFIED BY '${PASSWORD_DATABASE}';
GRANT ALL PRIVILEGES ON ${NAME_DATABASE}.* TO '${USERNAME_DATABASE}'@'%';
FLUSH PRIVILEGES;
EOF
    echo "Database and user created."
else
    echo "Database already initialized, skipping setup."
fi

kill $pid
exec "$@"