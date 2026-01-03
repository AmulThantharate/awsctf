#!/bin/bash
set -e

echo "[*] Destroying CTF Challenge Infrastructure..."

# Destroy Infrastructure
cd infrastructure
terraform destroy -auto-approve

echo "[+] Infrastructure Destroyed"
