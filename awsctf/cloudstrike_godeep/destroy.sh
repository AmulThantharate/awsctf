#!/bin/bash
set -e

echo "[-] Destroying CloudStrike Infrastructure..."
cd terraform
terraform destroy -auto-approve
echo "[-] Destruction Complete"
