variable "name_prefix" {
  description = "Prefix used to name the EC2 resources."
  type        = string
  default     = "tsn"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment must be development, staging, or production."
  }
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance is launched."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the EC2 instance."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided."
  }
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional AMI ID. When null, the latest Ubuntu Server 24.04 LTS amd64 gp3 AMI is resolved from the AWS public SSM parameter."
  type        = string
  default     = null
  nullable    = true
}

variable "associate_public_ip_address" {
  description = "Whether the instance receives a public IPv4 address."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "root_volume_size must be at least 8 GiB."
  }
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2"], var.root_volume_type)
    error_message = "root_volume_type must be gp3 or gp2."
  }
}

variable "root_volume_iops" {
  description = "Provisioned IOPS for a gp3 root volume."
  type        = number
  default     = 3000

  validation {
    condition     = var.root_volume_iops >= 3000 && var.root_volume_iops <= 16000
    error_message = "root_volume_iops must be between 3000 and 16000."
  }
}

variable "root_volume_throughput" {
  description = "Provisioned throughput in MiB/s for a gp3 root volume."
  type        = number
  default     = 125

  validation {
    condition     = var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000
    error_message = "root_volume_throughput must be between 125 and 1000 MiB/s."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enables one-minute EC2 monitoring. This has an additional cost."
  type        = bool
  default     = false
}

variable "enable_termination_protection" {
  description = "Protects the instance from API termination. Keep false in disposable development environments."
  type        = bool
  default     = false
}

variable "application_directory" {
  description = "Directory created on the instance for application deployment files."
  type        = string
  default     = "/opt/the-social-network"

  validation {
    condition     = startswith(var.application_directory, "/opt/")
    error_message = "application_directory must be an absolute path under /opt."
  }
}

variable "tags" {
  description = "Additional tags applied to the EC2 instance and root volume."
  type        = map(string)
  default     = {}
}
