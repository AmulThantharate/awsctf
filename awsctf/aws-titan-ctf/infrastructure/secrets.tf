resource "random_id" "secret_suffix" { byte_length = 4 }

resource "aws_secretsmanager_secret" "flag_secret" {
  name = "production/database/master-key-${random_id.secret_suffix.hex}"
  # Force deletion without recovery for easy teardown
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "flag_secret_val" {
  secret_id = aws_secretsmanager_secret.flag_secret.id
  secret_string = jsonencode({
    "flag" : "flag{s3cr3ts_m4n4g3r_1nt3rc3pt10n_m4st3r}",
    "note" : "Congratulations on bypassing the vault security."
  })
}
