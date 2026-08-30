variable "name_prefix" {
  description = "Prefix used to name monitoring resources."
  type        = string
  default     = "tsn"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance being monitored."
  type        = string
}

variable "notification_email" {
  description = "Optional email address subscribed to infrastructure alerts."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 14
}

variable "cpu_threshold" {
  description = "CPU percentage that triggers the high-CPU alarm."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Additional tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
