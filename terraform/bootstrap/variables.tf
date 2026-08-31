variable "aws_region" {
  description = "AWS Region where the Terraform state bucket is created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "the-social-network"
}

variable "owner" {
  description = "Owner tag applied to the bootstrap resources."
  type        = string
}

variable "state_bucket_name" {
  description = "Optional custom S3 bucket name. When null, a globally unique name is generated from the project, account ID, and Region."
  type        = string
  default     = null

  validation {
    condition     = var.state_bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be null or a valid S3 bucket name."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days to retain noncurrent state object versions."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 30
    error_message = "Noncurrent state versions must be retained for at least 30 days."
  }
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "Infrastructure repository name."
  type        = string
  default     = "the-social-network-infrastructure"
}

variable "github_environment" {
  description = "GitHub Environment used by the Terraform apply workflow."
  type        = string
  default     = "development"
}
