# --- DISTRACTORS (Rabbit Holes) ---

# 1. Fake Admin Policy (Requires MFA - impossible for attacker)
resource "aws_iam_policy" "fake_admin_policy" {
  name        = "AdministratorAccess-MFA-Verified"
  description = "Provides full access if MFA is present"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" : "true"
          }
        }
      }
    ]
  })
}

# Attach to the EC2 role so they see it and waste time trying to enable MFA
resource "aws_iam_role_policy_attachment" "attach_fake_admin" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.fake_admin_policy.arn
}

# 2. Fake Lambda Role (Dead End)
resource "aws_iam_role" "fake_lambda_role" {
  name = "go-app-maintenance-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fake_lambda_policy" {
  name = "go-app-maintenance-logs"
  role = aws_iam_role.fake_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = "arn:aws:s3:::some-non-existent-bucket-999"
      }
    ]
  })
}

# Add a fake trust relationship or something allowing EC2 to *see* this role?
# Actually, just having it in the account is enough for `iam:ListRoles` enumeration.
