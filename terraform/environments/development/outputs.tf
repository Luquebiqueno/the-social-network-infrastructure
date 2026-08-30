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

output "monitoring_topic_arn" {
  description = "ARN of the SNS topic used for infrastructure alerts."
  value       = module.monitoring.sns_topic_arn
}
