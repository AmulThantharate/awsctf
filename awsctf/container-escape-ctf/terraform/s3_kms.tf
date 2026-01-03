resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_kms_key" "flag_key" {
  description             = "KMS key to encrypt the flag"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "flag_bucket" {
  bucket = "${var.project_name}-flag-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flag_bucket_encrypt" {
  bucket = aws_s3_bucket.flag_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.flag_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.flag_bucket.id
  key     = "flag.txt"
  content = "FLAG{CLOUD_BREACH_MASTER_SUCCESS}"

  # Ensure it uses the KMS key
  kms_key_id             = aws_kms_key.flag_key.arn
  server_side_encryption = "aws:kms"
}
