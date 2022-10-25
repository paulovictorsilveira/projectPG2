output "WordPress" {
  value = "http://${aws_instance.wordpress.public_ip}"
}
