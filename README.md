# 🌩️ AWS Cloud Security CTF Collection

Welcome to the **AWS Cloud Security CTF Collection**. This repository contains a set of high-fidelity, real-world inspired Capture The Flag (CTF) challenges designed to test your skills in AWS exploitation, container security, and network pivot attacks.

[![Release](https://img.shields.io/github/v/release/AmulThantharate/awsctf)](https://github.com/AmulThantharate/awsctf/releases)
[![Docker](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/AmulThantharate/awsctf/pkgs/container/awsctf)

> **⚠️ WARNING**: These challenges deploy **intentionally vulnerable infrastructure** into your AWS account.
> - **DO NOT** deploy this in a production account.
> - **DO NOT** leave resources running; they will incur costs and pose security risks.
> - **ALWAYS** destroy resources immediately after completion.
---

## 📂 Challenges Overview

| Challenge Name | Difficulty | Description | Setup Method |
| :--- | :--- | :--- | :--- |
| **CloudStrike: GoDeep** | Insane 🤯 | A complex multi-stage attack involving LFI, log poisoning, IAM keys enumeration, CodeBuild privilege escalation, and SSM abuse. | Terraform |
| **Container Escape** | Hard 🔥 | Focuses on breaking out of a containerized environment within AWS credentials and host access. | Terraform |
| **SSRF & RCE Challenge** | Medium 🌶️ | Classic web vulnerabilities leading to cloud exploitation. Features SSRF bypasses and command injection. | Shell Script (`deploy.sh`) |

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **AWS CLI**: [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - Configured with `Admin` privileges: `aws configure`
2.  **Terraform**: [Install Guide](https://developer.hashicorp.com/terraform/downloads)
3.  **Docker** (Required if using the containerized CLI): [Install Guide](https://docs.docker.com/get-docker/)

---

## 🚀 Getting Started

### ⚡ Installation

#### Option 1: Docker (Recommended)
The easiest way to run `awsctf` without installing Go or Terraform locally is to use the official Docker image.
```bash
docker pull ghcr.io/amulthantharate/awsctf:latest
```

To run a command:
```bash
docker run --rm -it \
  -v ~/.aws:/root/.aws \
  -v $(pwd):/app \
  ghcr.io/amulthantharate/awsctf:latest help
```

#### Option 2: Binary Release
Download the latest binary for your OS from the [Releases](https://github.com/AmulThantharate/awsctf/releases) page.

#### Option 3: Homebrew (macOS/Linux)
```bash
brew install AmulThantharate/homebrew-tap/awsctf
```

---

### ⚡ Quick Start with `awsctf` CLI

Once installed, follow these steps:

1. **Configure Credentials**:
   ```bash
   awsctf config aws
   ```
   *Follow the prompts to enter your AWS Access Key, Secret Key, and Region.*

2. **List Scenarios**:
   ```bash
   awsctf list
   ```

3. **Deploy a Scenario**:
   ```bash
   awsctf create <scenario_name>
   # Example: awsctf create cloudstrike_godeep
   ```

4. **Destroy a Scenario**:
   ```bash
   awsctf destroy <scenario_name>
   # Example: awsctf destroy cloudstrike_godeep
   ```

---

### Manual Setup (Legacy)

If you prefer to run things manually or don't want to use the CLI, you can use the instructions below.

#### 1. CloudStrike: GoDeep (Insane)
An advanced scenario simulating a compromised internal application.

**Setup:**
```bash
cd awsctf/cloudstrike_godeep/terraform
terraform init
terraform apply
```

**Teardown:**
```bash
terraform destroy
```

#### 2. Container Escape CTF
A challenge focused on container isolation breakout techniques.

**Setup:**
```bash
cd awsctf/container-escape-ctf/terraform
terraform init
terraform apply
```

**Teardown:**
```bash
terraform destroy
```

---

## 🛑 Important Notes

- **Cost Warning**: These labs use real AWS resources (EC2, ECR, Load Balancers, NAT Gateways, etc.). Be mindful of costs.
- **Security**: The deployed resources are vulnerable by design. Access is typically restricted by security groups, but do not host sensitive data in the account used for these labs.

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is for educational purposes only.

**Author**: Amul Thantharate
**GitHub**: [AmulThantharate](https://github.com/AmulThantharate)
**LinkedIn**: [Amul Thantharate](https://www.linkedin.com/in/amul-thantharate/)
**Email**: amul.thantharate@gmail.com
