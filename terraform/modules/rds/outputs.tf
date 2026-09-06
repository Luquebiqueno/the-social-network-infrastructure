output "db_instance_id" {
  description = "ID of the RDS instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_instance_address" {
  description = "Hostname of the RDS instance."
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "Connection endpoint of the RDS instance, in host:port format."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "Port the RDS instance accepts connections on."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Name of the default database created on the instance."
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "Master username configured on the instance."
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret holding the master password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  description = "ID of the security group controlling access to the RDS instance."
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group used by the RDS instance."
  value       = aws_db_subnet_group.this.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key created by this module for RDS encryption, or null when kms_key_id and master_user_secret_kms_key_id were both supplied explicitly."
  value       = try(aws_kms_key.rds[0].arn, null)
}
