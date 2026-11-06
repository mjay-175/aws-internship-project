#!/bin/bash
set -euo pipefail

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

echo "Updating packages..."
apt-get update

echo "Installing Apache2..."
apt-get install -y apache2

echo "Enabling and starting Apache2..."
systemctl enable apache2
systemctl start apache2

echo "Deploying application files..."
# Note: This script assumes files (index.html, style.css, health.html) are in the same directory as the script.
cp index.html style.css health.html /var/www/html/

echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

echo "Testing Apache configuration..."
apache2ctl configtest

echo "Restarting Apache..."
systemctl restart apache2

echo "Application deployed successfully! You can access it via the EC2 instance's Public IP or DNS."

# Sync style.css to S3
echo "Note: If you have configured S3, you can sync the static assets using:"
echo "aws s3 cp /var/www/html/style.css s3://malavika-internship-bucket-2026/assets/style.css"
