variable "aws_region" {
  description = "AWS Region used by the development environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags."
  type        = string
  default     = "the-social-network"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "development"

  validation {
    condition     = var.environment == "development"
    error_message = "This root module manages only the development environment."
  }
}

variable "owner" {
  description = "Owner tag applied to development resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the development VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "IPv4 CIDR blocks assigned to public subnets."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "IPv4 CIDR blocks assigned to private subnets."
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to reach the application over HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed to reach the application over HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type used by the development application host."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "EC2 root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "ecr_repository_names" {
  description = "Docker image repositories created for the application."
  type        = set(string)
  default     = ["backend", "frontend"]
}

variable "alert_email" {
  description = "Optional email address subscribed to infrastructure alerts."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}
