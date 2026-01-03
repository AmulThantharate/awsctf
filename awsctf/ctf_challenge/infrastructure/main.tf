terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- Network ---
resource "aws_vpc" "ctf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "ctf-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ctf_vpc.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ctf_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "ctf-subnet-public" }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.ctf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

# --- Security Groups ---
resource "aws_security_group" "web_sg" {
  name        = "ctf_web_sg"
  description = "Allow HTTP inbound"
  vpc_id      = aws_vpc.ctf_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- IAM Role for EC2 #1 ---
resource "aws_iam_role" "ec2_role" {
  name = "CTF_SSRF_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ctf_policy" {
  name        = "CTF_Policy"
  description = "Permissions for CTF Challenge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ctf_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "CTF_Instance_Profile"
  role = aws_iam_role.ec2_role.name
}

# --- ECR ---
resource "aws_ecr_repository" "secret_repo" {
  name                 = "ctf-secret-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# --- EC2 Instances ---

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "ec2_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "CTF-Web-Gateway"
    Flag = "user{fl4g_1n_t4gs}"
  }

  user_data = templatefile("${path.module}/../scripts/setup_ec2_1.sh", {
    app_code = file("${path.module}/../app1_ssrf/app.py")
  })
}

resource "aws_instance" "ec2_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "CTF-internal-Target"
  }

  user_data = templatefile("${path.module}/../scripts/setup_ec2_2.sh", {
    app_code = file("${path.module}/../app2_rce/app.py")
  })
}

output "entry_point_url" {
  value = "http://${aws_instance.ec2_1.public_ip}/"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.secret_repo.repository_url
}

output "secret_target_ip" {
  value = aws_instance.ec2_2.public_ip
  # Using public_ip so the user can actually reach it from their machine directly
  # as per the simplified network model where we are not tunnelling through EC2 #1.
}
