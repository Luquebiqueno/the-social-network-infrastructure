variable "name_prefix" {
  description = "Prefix used to name networking resources."
  type        = string
  default     = "tsn"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by public and private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "IPv4 CIDR blocks assigned to public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "IPv4 CIDR blocks assigned to private subnets."
  type        = list(string)
}

variable "tags" {
  description = "Additional tags applied to networking resources."
  type        = map(string)
  default     = {}
}
