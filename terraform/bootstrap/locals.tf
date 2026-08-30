locals {
  name_prefix = "tsn"

  state_bucket_name = coalesce(
    var.state_bucket_name,
    "${local.name_prefix}-terraform-state-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  )

  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}
