# 🌩️ CloudStrike: The Insane AWS CTF Challenge 🌩️

> **Difficulty**: Insane 🤯  
> **Environment**: AWS (EC2, IAM, CodeBuild, S3, SSM)  
> **Entry Point**: Vulnerable Go Web App

---

## 📜 Scenario

Welcome to **CloudStrike**. You have discovered a legacy internal notes application running on a hidden EC2 instance exposed to the internet. The developers claim it's secure because "Go is memory safe" and "it runs in the cloud."

Your mission, should you choose to accept it, is to penetrate this fortress, compromise the host, navigate the treacherous IAM policies, and ultimately gain **Root** access to retrieve the final flag.

Beware of rabbit holes! 🐇🕳️ Not everything is what it seems.

## 🏗️ Architecture

```mermaid
graph TD
    User[🕵️ Attacker] -->|LFI ?page=...| App[🐹 Vulnerable Go App]
    App -->|Log Poisoning| Nginx[🕸️ Nginx Logs]
    Nginx -->|RCE| Shell[🐚 Reverse Shell (ec2-user)]
    Shell -->|IMDS Credentials| IAM[🔑 IAM Role: ec2-profile]
    IAM -->|Enumeration| Cloud[☁️ AWS Cloud]
    Cloud -->|StartBuild Override| CodeBuild[🏗️ CodeBuild: LegacyApp]
    CodeBuild -->|PrivEsc| SSM[🔧 SSM / IAM Abuse]
    SSM -->|sudo chown| Root[💀 ROOT ACCESS]
```

### ASCII Architecture Diagram

```
┌─────────────┐    LFI         ┌─────────────────┐
│ 🕵️ Attacker │ ──────────────▶│ 🐹 Go Web App   │
└─────────────┘       └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 🕸️ Nginx Logs   │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 🐚 Shell        │
                                │ (ec2-user)      │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 🔑 IAM Role     │
                                │ ec2-profile     │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ ☁️ AWS Cloud     │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 🏗️ CodeBuild     │
                                │ LegacyApp       │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 🔧 SSM/IAM      │
                                └─────────────────┘
                                        │
                                        │ 
                                        ▼
                                ┌─────────────────┐
                                │ 💀 ROOT ACCESS  │
                                └─────────────────┘
```

### Attack Path Summary

1. **LFI Exploitation** → Log Poisoning → RCE → Shell (ec2-user)
2. **IMDS Credentials** → IAM Role enumeration  
3. **AWS Service Abuse** → CodeBuild privilege escalation
4. **SSM/IAM Manipulation** → Root access

## 🚩 Objectives

1.  **Initial Access**: Exploit the Go Application to gain a shell. 🐚
2.  **Lateral Movement**: Escalate from local execution to Cloud Identity. ☁️
3.  **Privilege Escalation**: Use your cloud permissions to gain lateral movement to other services. 🧱
4.  **The Crown Jewels**: Abuse misconfigured SUDO permissions to claim the root flag. 👑

## 🛠️ Deployment Instructions

### Prerequisites

- Terraform installed 📦
- AWS CLI configured with Admin credentials API keys 🔑

### Setup

1.  Navigate to the terraform directory:
    ```bash
    cd terraform
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Deploy the infrastructure:
    ```bash
    terraform apply -auto-approve
    ```
4.  Wait for the EC2 instance to initialize (mins). Get the IP from Terraform output:
    ```bash
    export TARGET_IP=$(terraform output -raw instance_public_ip)
    ```

## 🛑 Rules of Engagement & Disclaimer

- **DO NOT** attack infrastructure you do not own.
- This project is for **EDUCATIONAL PURPOSES ONLY**.
- Do not leave this running! It is intentionally vulnerable. 💣
- **Destroy** resources immediately after finishing:
  ```bash
  terraform destroy -auto-approve
  ```

_Happy Hacking!_ 🏴‍☠️
