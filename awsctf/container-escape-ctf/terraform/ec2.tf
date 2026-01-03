resource "aws_security_group" "ctf_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

locals {
  # Base64 encode files to safely inject into User Data
  requirements_txt = base64encode(file("${path.module}/../app/requirements.txt"))
  dockerfile       = base64encode(file("${path.module}/../app/Dockerfile"))
  entrypoint_sh    = base64encode(file("${path.module}/../app/entrypoint.sh"))
  backup_sh        = base64encode(file("${path.module}/../app/backup.sh"))
  app_py           = base64encode(file("${path.module}/../app/app.py"))
  index_html       = base64encode(file("${path.module}/../app/templates/index.html"))
  upload_html      = base64encode(file("${path.module}/../app/templates/upload.html"))
}

resource "aws_instance" "ctf_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ctf_sg.id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    requirements_txt_b64 = local.requirements_txt
    dockerfile_b64       = local.dockerfile
    entrypoint_sh_b64    = local.entrypoint_sh
    backup_sh_b64        = local.backup_sh
    app_py_b64           = local.app_py
    index_html_b64       = local.index_html
    upload_html_b64      = local.upload_html
  })

  tags = {
    Name = "${var.project_name}-server"
  }
}

output "instance_ip" {
  value = aws_instance.ctf_server.public_ip
}
