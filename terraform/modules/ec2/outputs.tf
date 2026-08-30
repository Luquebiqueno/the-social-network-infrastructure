output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IPv4 address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance, when assigned."
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.this.private_dns
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance, when assigned."
  value       = aws_instance.this.public_dns
}

output "ami_id" {
  description = "AMI ID used to launch the EC2 instance."
  value       = aws_instance.this.ami
}

output "application_directory" {
  description = "Application deployment directory created on the instance."
  value       = var.application_directory
}
