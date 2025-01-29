
output "ansible_controller_ip" {
  value = aws_instance.ansible_controller.public_ip
}

output "web_servers_ips" {
  value = aws_instance.webserver.public_ip
}
