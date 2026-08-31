output "state_bucket_name" {
  description = "S3 bucket used by Terraform environments for remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "development_backend_configuration" {
  description = "Backend values to copy into the development environment."
  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    key          = "environments/development/terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
