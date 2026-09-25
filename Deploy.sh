#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <zip-url | local-zip-path | local-folder-path>"
    exit 1
fi

SOURCE="$1"
WORK_DIR="/tmp/landingpage"
WEB_ROOT="/var/www/html"

echo "==> Installing dependencies..."
yum install httpd wget unzip vim -y

echo "==> Starting and enabling httpd..."
systemctl start httpd
systemctl enable httpd

echo "==> Preparing work directory..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ---- Figure out what kind of source we were given ----
if [[ "$SOURCE" =~ ^https?:// ]]; then
    echo "==> Detected URL. Downloading..."
    wget -O site.zip "$SOURCE"
    echo "==> Unzipping..."
    unzip -o site.zip -d extracted

elif [ -d "$SOURCE" ]; then
    echo "==> Detected local folder. Copying it in..."
    mkdir -p extracted
    cp -r "$SOURCE"/* extracted/

elif [ -f "$SOURCE" ] && [[ "$SOURCE" == *.zip ]]; then
    echo "==> Detected local zip file. Unzipping..."
    unzip -o "$SOURCE" -d extracted

else
    echo "Could not recognize source: $SOURCE"
    echo "Provide a zip URL, a path to a .zip file, or a path to a folder."
    exit 1
fi

# ---- Handle both cases: files extracted directly, or nested inside one subfolder ----
cd extracted
ITEM_COUNT=$(find . -mindepth 1 -maxdepth 1 | wc -l)
if [ "$ITEM_COUNT" -eq 1 ] && [ -d "$(find . -mindepth 1 -maxdepth 1)" ]; then
    # Single subfolder inside — go into it
    cd "$(find . -mindepth 1 -maxdepth 1)"
fi

echo "==> Clearing old web root content..."
rm -rf "${WEB_ROOT:?}"/*

echo "==> Copying site files to $WEB_ROOT..."
cp -r ./* "$WEB_ROOT"/

echo "==> Fixing permissions and SELinux context (if applicable)..."
chown -R apache:apache "$WEB_ROOT" 2>/dev/null || true
restorecon -Rv "$WEB_ROOT" 2>/dev/null || true

echo "==> Restarting httpd..."
systemctl restart httpd

echo "==> Cleaning up temp directory..."
cd /tmp
rm -rf "$WORK_DIR"

echo "==> Fetching server IP..."
IP_ADDR=$(ip -4 addr show | awk '/inet 192\.168\.56\./ {print $2}' | cut -d/ -f1)
echo "============================================================"
echo " Deployment complete!"
echo " Open this in your browser: http://$IP_ADDR"
echo "============================================================"