resource "aws_codebuild_project" "build_project" {
  name          = "LegacyAppBuild"
  description   = "Build project for the legacy Go application"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true # Often needed for Docker builds, useful for container escape scenarios if we were doing that, though here we just want IAM abuse.
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<EOF
version: 0.2
phases:
  build:
    commands:
      - echo "Building Legacy App..."
      - echo "Nothing to see here."
EOF
  }
}
