#!/bin/bash

# Exit on error
set -e

# Define variables
APP_DIR="/opt/csye6225"
APP_USER="appuser"
APP_GROUP="csye6225"
LOG_FILE="/var/log/setup.log"

# Logging setup
exec > >(tee -i $LOG_FILE)
exec 2>&1

echo "Starting WebApp Setup"

# 1️⃣pdate System Packages**
echo "Updating system"
sudo apt update -y && sudo apt upgrade -y

# 2️⃣ stall Required Packages**
echo " Installing required packages"
sudo apt install -y unzip curl git mysql-server npm

# 3️⃣ sure MySQL is Running***
echo "Ensuring MySQL is running"
sudo systemctl enable mysql
sudo systemctl start mysql

# 4️⃣ sure `APP_DIR` Exists B
echo "Ensuring application directory exists"
sudo mkdir -p $APP_DIR

sudo mv .env $APP_DIR/

sudo chmod 644 $APP_DIR/.env

cat -A $APP_DIR/.env

# 5️⃣oad `.env` Variables from WebApp Folder**
if [[ -f $APP_DIR/.env ]]; then
    echo "Loading environment variables from .env"
    export $(grep -v '^#' $APP_DIR/.env | xargs)
else
    echo "ERROR: .env file not found in $APP_DIR. Please upload it."
    exit 1
fi

# 6️⃣ eck if Database Exists & Create if Missing**
echo "Checking if database '$DB_NAME' exists"
DB_EXISTS=$(sudo mysql -u "$DB_USER" -p"$DB_PASS" -se "SHOW DATABASES LIKE '$DB_NAME';")

if [ "$DB_EXISTS" == "$DB_NAME" ]; then
    echo "Database '$DB_NAME' already exists."
else
    echo " Creating database '$DB_NAME'..."
    sudo mysql -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE $DB_NAME;"
    echo "Database '$DB_NAME' created successfully."
fi

# 7️⃣ eate Linux User & Group**
echo "Checking if application group and user exist..."

# Create group if it doesn't exist
if getent group "$APP_GROUP" > /dev/null 2>&1; then
    echo "Group '$APP_GROUP' already exists."
else
    sudo groupadd "$APP_GROUP"
    echo "Group '$APP_GROUP' created."
fi

# Create user if it doesn't exist
if id "$APP_USER" > /dev/null 2>&1; then
    echo "User '$APP_USER' already exists."
else
    sudo useradd -m -g "$APP_GROUP" -s /bin/bash "$APP_USER"
    echo "User '$APP_USER' created."
fi

# 8️⃣nzip and Setup Application**
echo "Extracting application..."
if [[ -f "webapp.zip" ]]; then
    sudo unzip -o webapp.zip -d $APP_DIR
else
    echo "ERROR: webapp.zip not found. Please upload your application."
    exit 1
fi

# 9️⃣ pdate Permissions**
echo "Setting permissions..."
sudo chown -R $APP_USER:$APP_GROUP $APP_DIR
sudo chmod -R 750 $APP_DIR

# 10 Restart MySQL to Apply Changes**
echo "Restarting MySQL..."
sudo systemctl restart mysql

echo "MySQL and WebApp setup completed successfully!"
