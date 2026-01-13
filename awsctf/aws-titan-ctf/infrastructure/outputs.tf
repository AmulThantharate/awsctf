output "victim_ip" { value = aws_instance.victim_server.public_ip }
output "secret_arn" { value = aws_secretsmanager_secret.flag_secret.arn }
