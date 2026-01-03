#!/bin/bash
# Setup script for EC2 #1

apt-get update
apt-get install -y python3-pip python3-flask

mkdir -p /opt/app

# Inject App Code from Terraform Variable
cat <<'EOF' > /opt/app/app.py
${app_code}
EOF

cat <<EOF > /etc/systemd/system/ctf-app.service
[Unit]
Description=CTF App 1
After=network.target

[Service]
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ctf-app
systemctl start ctf-app

echo "Hint: :emojiee :emoji: :emoji:" > /home/ubuntu/hint.txt
