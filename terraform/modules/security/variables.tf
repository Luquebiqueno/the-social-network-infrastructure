variable "name_prefix" {
  description = "Prefix used to name security resources."
  type        = string
  default     = "tsn"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EC2 security group is created."
  type        = string
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to reach port 80."
  type        = list(string)
  default     = []
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed to reach port 443."
  type        = list(string)
  default     = []
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the EC2 instance may pull images from."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to security resources."
  type        = map(string)
  default     = {}
}
