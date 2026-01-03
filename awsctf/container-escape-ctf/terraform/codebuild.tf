resource "aws_codebuild_project" "ctf_project" {
  name          = "${var.project_name}-setup"
  description   = "A project that has access to the flag"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<EOF
version: 0.2
phases:
  build:
    commands:
      - echo "This is a dummy build. Use buildspec override to get the flag."
EOF
  }
}
