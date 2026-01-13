#!/bin/bash
apt-get update
apt-get install -y docker.io python3-pip python3-flask awscli jq gcc libcurl4-openssl-dev
systemctl enable --now docker

mkdir -p /app
cd /app

# 1. Vulnerable Flask (Same as before)
cat <<EOF > /app/app.py
from flask import Flask, request
import requests, socket, ipaddress, subprocess
from urllib.parse import urlparse
app = Flask(__name__)
def is_safe_url(url):
    try:
        ip = socket.gethostbyname(urlparse(url).hostname)
        return not ipaddress.ip_address(ip).is_private
    except: return False
@app.route('/')
def home(): return '<h1>Secure Fetcher v5</h1><form action="/fetch"><input name="url"><input type="submit"></form><form action="/ping"><input name="target"><input type="submit"></form>'
@app.route('/fetch')
def fetch():
    url = request.args.get('url')
    if not is_safe_url(url): return "Blocked", 403
    try: return requests.get(url, timeout=2, allow_redirects=True).text
    except: return "Error"
@app.route('/ping')
def ping():
    try: return subprocess.check_output(f"ping -c 1 {request.args.get('target')}", shell=True).decode()
    except Exception as e: return str(e)
if __name__ == '__main__': app.run(host='0.0.0.0', port=5000)
EOF

# Dockerfile
cat <<EOF > /app/Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY app.py .
RUN pip install flask requests && apt-get update && apt-get install -y docker.io curl
CMD ["python", "app.py"]
EOF

docker build -t vuln-app .
docker run -d -p 5000:5000 -v /var/run/docker.sock:/var/run/docker.sock --name vuln-app vuln-app

# 2. Host-Level Bot targeting Secrets Manager
cat <<EOF > /app/bot.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <unistd.h>

int main(void) {
    CURL *curl;
    struct curl_slist *headers = NULL;
    
    // Target: Secrets Manager US-East-1
    const char *url = "https://secretsmanager.us-east-1.amazonaws.com/";
    const char *payload = "{\"SecretId\": \"${target_secret_arn}\"}";
    
    // We simulate Signed Headers (The attack relies on stealing the Auth Header)
    headers = curl_slist_append(headers, "Authorization: AWS4-HMAC-SHA256 Credential=${bot_access_key}/2026/us-east-1/secretsmanager/aws4_request, SignedHeaders=content-type;host;x-amz-date;x-amz-target, Signature=${bot_secret_key}");
    headers = curl_slist_append(headers, "Content-Type: application/x-amz-json-1.1");
    headers = curl_slist_append(headers, "X-Amz-Target: secretsmanager.GetSecretValue");
    headers = curl_slist_append(headers, "X-Amz-Date: 20260111T120000Z");

    while(1) {
        curl = curl_easy_init();
        if(curl) {
            curl_easy_setopt(curl, CURLOPT_URL, url);
            curl_easy_setopt(curl, CURLOPT_POST, 1L);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, payload);
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

            // Trust Store & Cert Vulnerability
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
            curl_easy_setopt(curl, CURLOPT_CAINFO, "/etc/pki/custom.pem");
            
            // Silence Output
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, fopen("/dev/null", "w+"));
            curl_easy_perform(curl);
            curl_easy_cleanup(curl);
        }
        sleep(20); 
    }
    return 0;
}
EOF

gcc /app/bot.c -o /usr/local/bin/secure-backup-bot -lcurl
rm /app/bot.c
chmod 700 /usr/local/bin/secure-backup-bot
chown root:root /usr/local/bin/secure-backup-bot

# 3. Setup
mkdir -p /etc/pki
cat /etc/ssl/certs/ca-certificates.crt > /etc/pki/custom.pem
chmod 666 /etc/pki/custom.pem /etc/hosts

nohup /usr/local/bin/secure-backup-bot > /dev/null 2>&1 &
