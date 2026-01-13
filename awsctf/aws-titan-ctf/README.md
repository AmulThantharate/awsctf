# Project TITAN: Advanced Cloud Security CTF

**Codename**: Operation Vault Breaker
**Difficulty**: Insane / God Mode
**Target Environment**: AWS (Simulated Enterprise Infrastructure)

---

## 1. Executive Summary
Project TITAN is a high-fidelity Capture The Flag (CTF) scenario designed to test advanced penetration testing skills in a modern, cloud-native environment. Unlike standard CTFs that rely on simple misconfigurations, TITAN simulates a hardened enterprise deployment featuring containerization, strict network filtering, and encrypted backend communications.

The objective is to compromise a "Secure URL Fetcher" service, escalate privileges through the container orchestration layer, and intercept high-value credentials from a background process targeting AWS Secrets Manager.

## 2. Technical Architecture
The environment is deployed via Terraform and consists of the following components:

*   **Front-End**: A Python Flask web application running inside a locked-down Docker container. It implements "secure" input validation and runs with limited privileges.
*   **Back-End Bot**: A compiled C binary (`secure-backup-bot`) running on the host OS. It performs periodic, encrypted API calls to AWS Secrets Manager using hardcoded, obfuscated credentials.
*   **Security Controls**:
    *   **Network**: App runs in a private container network. direct access to Metadata Service (IMDS) is filtered.
    *   **Cryptographic**: The Bot enforces SSL/TLS verification for all outbound connections.
    *   **IAM**: The Host EC2 instance has **Zero Permissions**. Standard AWS enumeration techniques (SSM, S3 ls) will fail.

## 3. Kill Chain Overview
To retrieve the Flag, the operator must execute a complex exploit chain:

1.  **Defense Evasion (SSRF)**: Bypass the application's DNS-based input filtering using a custom Redirection Trap.
2.  **Initial Access (RCE)**: Exploit a Command Injection vulnerability in the diagnostic interface.
3.  **Privilege Escalation (Container Breakout)**: Identify and exploit a misconfigured Docker Socket (`/var/run/docker.sock`) to escape the container and gain Root access to the Host OS.
4.  **Credential Access (Trust Store Poisoning)**: Analyze the SSL-verifying Bot, generate a malicious Certificate Authority (CA), and inject it into the system's Trust Store.
5.  **Exfiltration (MITM)**: Perform a local DNS poisoning attack to redirect the Bot's HTTPS traffic to a local listener, intercepting the `secretsmanager:GetSecretValue` signed request.

## 4. Getting Started
### Prerequisites
*   AWS CLI (Configured with Admin permissions)
*   Terraform v1.0+
*   OpenSSL (For solving the challenge)

### Deployment
1.  Navigate to the infrastructure directory:
    ```bash
    cd infrastructure
    ```
2.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```
3.  **Target IP**: Note the `victim_ip` output.


## 5. Artifacts
*   `infrastructure/`: Terraform code (Split into modules).
*   `scripts/`: User Data and payload generation logic.

## 6. Disclaimer
This project is for educational purposes only. It demonstrates theoretical vulnerabilities in misconfigured cloud environments. Do not use these techniques on systems you do not own.

---
**Project TITAN** | *Break the Vault.*
