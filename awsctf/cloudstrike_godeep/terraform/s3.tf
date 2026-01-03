resource "aws_s3_bucket" "backup" {
  bucket_prefix = "company-backup-"
  force_destroy = true
}

resource "aws_s3_object" "flag" {
  bucket  = aws_s3_bucket.backup.id
  key     = "flag.txt"
  content = "FLAG{NOT_ROOT_BUT_GOOD_TRY_KEEP_DIGGING}"
}
