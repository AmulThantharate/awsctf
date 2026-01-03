#!/bin/bash
# Setup script for EC2 #2

apt-get update
apt-get install -y python3-pip python3-flask

mkdir -p /opt/app

# Inject App Code from Terraform Variable
cat <<'EOF' > /opt/app/app.py
${app_code}
EOF

# Setup App Service (www-data on port 5000)
cat <<EOF > /etc/systemd/system/ctf-app.service
[Unit]
Description=CTF App 2
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Fix app port since we inject code that defaults to 80
sed -i 's/port=80/port=5000/g' /opt/app/app.py

systemctl daemon-reload
systemctl enable ctf-app
systemctl start ctf-app

# --- Privilege Escalation Setup: Tar Wildcard ---

# 1. Create a directory for backups that www-data can write to
mkdir -p /var/backups/webapp
chown www-data:www-data /var/backups/webapp

# 2. Create the backup script
cat <<EOF > /usr/local/bin/backup-log.sh
#!/bin/bash
cd /var/backups/webapp
# Vulnerability: Wildcard injection with tar
tar -czf /var/backups/archive.tar.gz *
EOF

chmod +x /usr/local/bin/backup-log.sh

# 3. Add to sudoers (simulating a backup operator role for the web app user)
echo "www-data ALL=(root) NOPASSWD: /usr/local/bin/backup-log.sh" >> /etc/sudoers

# Root Flag
echo "root{t4r_w1ldc4rd_m4st3r}" > /root/.flag.txt
chmod 600 /root/.flag.txt
