
output "publicIP" {
    value = aws_instance.app_server.public_ip
}

output "arn" {
    value = aws_instance.app_server.arn
}