#!/bin/bash
apt-get update
apt-get install -y docker.io

# Setup directory
mkdir -p /opt/ctf/app/templates

# Write files (Base64 decoded to avoid escaping issues)
echo "${requirements_txt_b64}" | base64 -d > /opt/ctf/app/requirements.txt
echo "${dockerfile_b64}" | base64 -d > /opt/ctf/app/Dockerfile
echo "${entrypoint_sh_b64}" | base64 -d > /opt/ctf/app/entrypoint.sh
echo "${backup_sh_b64}" | base64 -d > /opt/ctf/app/backup.sh
echo "${app_py_b64}" | base64 -d > /opt/ctf/app/app.py
echo "${index_html_b64}" | base64 -d > /opt/ctf/app/templates/index.html
echo "${upload_html_b64}" | base64 -d > /opt/ctf/app/templates/upload.html

# Fix permissions for scripts (just in case they lost +x)
chmod +x /opt/ctf/app/entrypoint.sh
chmod +x /opt/ctf/app/backup.sh

# Build and Run
cd /opt/ctf/app
docker build -t ctf_challenge .
# VULNERABILITY: Mounting docker socket
docker run -d --restart always -p 80:5000 -v /var/run/docker.sock:/var/run/docker.sock ctf_challenge
