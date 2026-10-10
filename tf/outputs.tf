output "wordpress_url" {
  description = "HTTP URL for the WordPress host."
  value       = "http://${aws_instance.wordpress.public_dns}"
}

output "instance_id" {
  description = "ID of the EC2 instance created for the assignment."
  value       = aws_instance.wordpress.id
}

output "public_ip" {
  description = "Public IPv4 address of the WordPress host."
  value       = aws_instance.wordpress.public_ip
}
