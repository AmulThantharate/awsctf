#!/bin/bash
set -e

# Deploy Infrastructure
echo "[*] Deploying Infrastructure with Terraform..."
cd infrastructure
terraform init
terraform apply -auto-approve

# Get Outputs
APP_URL=$(terraform output -raw entry_point_url)
ECR_URL=$(terraform output -raw ecr_repo_url)
TARGET_IP=$(terraform output -raw secret_target_ip)

echo "[+] Infrastructure Deployed"
echo "    Gateway URL: $APP_URL"
echo "    ECR Repo: $ECR_URL"
echo "    Target IP: $TARGET_IP"

# Login to ECR
echo "[*] Logging into ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build and Push Secret Image
echo "[*] Building and Pushing Secret Image..."
cd ../secret_image
# Update secrets.yaml with the real private IP if needed, or we rely on the user finding it via DescribeInstances.
# The `secrets.yaml` currently has a placeholder `10.0.1.50`.
# We should update it to the actual IP.
sed -i "s/target_ip: .*/target_ip: $TARGET_IP/" secrets.yaml

docker build -t secret-image .
docker tag secret-image:latest $ECR_URL:latest
docker push $ECR_URL:latest

echo "[*] Setup Complete!"
echo "    Challenge Access: $APP_URL"
