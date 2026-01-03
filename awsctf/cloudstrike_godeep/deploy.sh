#!/bin/bash
set -e

# Deploy Infrastructure
echo "[*] Deploying CloudStrike Infrastructure with Terraform..."
cd terraform
terraform init
terraform apply -auto-approve

# Get Outputs
TARGET_IP=$(terraform output -raw instance_public_ip)

echo ""
echo "[+] Infrastructure Deployed"
echo "    Target IP: $TARGET_IP"
echo "    Access: http://$TARGET_IP"
