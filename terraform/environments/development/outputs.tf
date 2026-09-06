output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the development public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the development private subnets."
  value       = module.networking.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID of the development EC2 instance."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the development EC2 instance."
  value       = module.ec2.public_ip
}

output "ecr_repository_urls" {
  description = "URLs of the application ECR repositories."
  value       = module.ecr.repository_urls
}

output "db_instance_endpoint" {
  description = "Connection endpoint of the development RDS instance, in host:port format."
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "Hostname of the development RDS instance."
  value       = module.rds.db_instance_address
}

output "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password."
  value       = module.rds.master_user_secret_arn
}

output "db_security_group_id" {
  description = "ID of the security group controlling access to the RDS instance."
  value       = module.rds.security_group_id
}

output "monitoring_topic_arn" {
  description = "ARN of the SNS topic used for infrastructure alerts."
  value       = module.monitoring.sns_topic_arn
}
