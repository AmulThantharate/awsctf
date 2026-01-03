#!/bin/bash
set -e

echo "[-] Destroying Container Escape CTF Infrastructure..."
cd terraform
terraform destroy -auto-approve
echo "[-] Destruction Complete"
