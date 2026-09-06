variable "name_prefix" {
  description = "Prefix used to name RDS resources."
  type        = string
  default     = "tsn"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance is created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the DB subnet group. Private subnets are strongly recommended."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs in different Availability Zones are required."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach PostgreSQL on port 5432."
  type        = list(string)
  default     = []
}

variable "database_name" {
  description = "Name of the default database created on the instance."
  type        = string
  default     = "the_social_network"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "database_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "master_username" {
  description = "Master username for the PostgreSQL instance."
  type        = string
  default     = "tsn_admin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.master_username))
    error_message = "master_username must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "engine_version" {
  description = "PostgreSQL engine version. The parameter group family is derived from its major version."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage must be at least 20 GiB."
  }
}

variable "max_allocated_storage" {
  description = "Upper limit in GiB for RDS storage autoscaling. Set to 0 to disable autoscaling."
  type        = number
  default     = 100

  validation {
    condition     = var.max_allocated_storage == 0 || var.max_allocated_storage >= var.allocated_storage
    error_message = "max_allocated_storage must be 0 (disabled) or greater than or equal to allocated_storage."
  }
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2"], var.storage_type)
    error_message = "storage_type must be gp3 or gp2."
  }
}

variable "kms_key_id" {
  description = "Optional KMS key ARN used to encrypt storage. When null, the default aws/rds key is used."
  type        = string
  default     = null
  nullable    = true
}

variable "master_user_secret_kms_key_id" {
  description = "Optional KMS key ARN used to encrypt the AWS-managed master password secret. When null, the default aws/secretsmanager key is used."
  type        = string
  default     = null
  nullable    = true
}

variable "multi_az" {
  description = "Deploys a standby replica in a second Availability Zone."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred daily backup window in UTC."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "mon:04:30-mon:05:30"
}

variable "deletion_protection" {
  description = "Protects the instance from accidental deletion. Keep false in disposable development environments."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skips the final snapshot on deletion. Keep true only in disposable development environments."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Applies changes immediately instead of during the next maintenance window."
  type        = bool
  default     = true
}

variable "force_ssl" {
  description = "Forces SSL/TLS for all PostgreSQL connections via the DB parameter group."
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Enables RDS Performance Insights."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags applied to RDS resources."
  type        = map(string)
  default     = {}
}
