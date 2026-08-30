variable "name_prefix" {
  description = "Prefix used to name ECR repositories."
  type        = string
  default     = "tsn"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "repository_names" {
  description = "Logical names of the ECR repositories."
  type        = set(string)

  validation {
    condition     = length(var.repository_names) > 0
    error_message = "At least one ECR repository name must be provided."
  }
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "max_image_count" {
  description = "Maximum number of tagged images retained per repository."
  type        = number
  default     = 20

  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}

variable "force_delete" {
  description = "Allows repository deletion when it still contains images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}
