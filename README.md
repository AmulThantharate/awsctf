# 🌩️ AWS Cloud Security CTF Collection

Welcome to the **AWS Cloud Security CTF Collection**. This repository contains a set of high-fidelity, real-world inspired Capture The Flag (CTF) challenges designed to test your skills in AWS exploitation, container security, and network pivot attacks.

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
3.  **Docker** (required for some challenges): [Install Guide](https://docs.docker.com/get-docker/)
4.  **Go** (optional, for local analysis): [Install Guide](https://go.dev/doc/install)

---

## 🚀 Getting Started

### ⚡ Installation

#### Option 1: Homebrew (macOS/Linux)
```bash
brew install Amul-Thantharate/tap/awsctf
```

#### Option 2: Binary Release
Download the latest binary from the [Releases](https://github.com/Amul-Thantharate/awsctf/releases) page.

#### Option 3: Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/Amul-Thantharate/awsctf.git
   cd awsctf
   ```
2. Build the binary:
   ```bash
   go build -o bin/awsctf main.go
   ```

### ⚡ Quick Start with `awsctf` CLI

Once installed (if built from source, use `./bin/awsctf`), follow these steps:

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
./bin/awsctf create cloudstrike_godeep
# OR manually:
cd awsctf/cloudstrike_godeep/deploy.sh
./deploy.sh
```

**Start Hacking:**
- Wait for the output to provide the `Target IP`.
- Access the application at `http://<TARGET_IP>`.

**Teardown:**
```bash
./bin/awsctf destroy cloudstrike_godeep
# OR manually:
./awsctf/cloudstrike_godeep/destroy.sh
```

#### 2. Container Escape CTF

A challenge focused on container isolation breakout techniques.

**Setup:**
```bash
./bin/awsctf create container-escape-ctf
# OR manually:
./awsctf/container-escape-ctf/deploy.sh
```

**Start Hacking:**
- Use the `Target IP` from the output to access the initial entry point.

**Teardown:**
```bash
./bin/awsctf destroy container-escape-ctf
# OR manually:
./awsctf/container-escape-ctf/destroy.sh
```

#### 3. SSRF & RCE Challenge

A scenario combining Server-Side Request Forgery and Remote Code Execution.

**Setup:**
```bash
./bin/awsctf create ctf_challenge
# OR manually:
cd awsctf/ctf_challenge
chmod +x deploy.sh
./deploy.sh
```

**Teardown:**
```bash
./bin/awsctf destroy ctf_challenge
```

---

## 🛑 Important Notes

- **Cost Warning**: These labs use real AWS resources (EC2, ECR, Load Balancers, NAT Gateways, etc.). Be mindful of costs.
- **Security**: The deployed resources are vulnerable by design. Access is typically restricted by security groups, but do not host sensitive data in the account used for these labs.
- **Homebrew**: If you installed using Homebrew, use `brew upgrade awsctf` to update.

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is for educational purposes only.

**Author**: Amul Thantharate
**GitHub**: [Amul-Thantharate](https://github.com/Amul-Thantharate)
**Twitter**: [AmulThantharate](https://twitter.com/AmulThantharate)
**LinkedIn**: [Amul Thantharate](https://www.linkedin.com/in/amul-thantharate/)
**Email**: amul.thantharate@gmail.com
