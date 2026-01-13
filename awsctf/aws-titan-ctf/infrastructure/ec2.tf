data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "victim_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = { Name = "${var.project_name}-victim" }

  # Updated path to point to the scripts folder
  user_data = templatefile("${path.module}/../scripts/user_data.sh", {
    target_secret_arn = aws_secretsmanager_secret.flag_secret.arn
    bot_access_key    = aws_iam_access_key.bot_key.id
    bot_secret_key    = aws_iam_access_key.bot_key.secret
  })
}
