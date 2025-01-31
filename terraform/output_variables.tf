

output "web_servers_ips" {
  value = aws_instance.webserver.public_ip
}
