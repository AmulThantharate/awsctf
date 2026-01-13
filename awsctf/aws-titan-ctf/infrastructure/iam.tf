# --- EC2 Role (Unprivileged) ---
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      # NO SSM - RCE Only via Web App
      Action   = ["lambda:InvokeFunction"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# --- Bot Identity (Secrets Manager Access) ---
resource "aws_iam_user" "bot_user" {
  name = "${var.project_name}-bot-user"
}

resource "aws_iam_access_key" "bot_key" {
  user = aws_iam_user.bot_user.name
}

resource "aws_iam_user_policy" "bot_policy" {
  name = "${var.project_name}-bot-policy"
  user = aws_iam_user.bot_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.flag_secret.arn
    }]
  })
}
