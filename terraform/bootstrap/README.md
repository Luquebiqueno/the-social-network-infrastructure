# Terraform Bootstrap

Creates the AWS resources required before the application environments can use a remote Terraform state.

## Why this directory exists

Terraform needs a state file to map HCL resources to real AWS resources. The `development` environment stores that state in Amazon S3, but the S3 bucket must exist before Terraform can initialize the remote backend.

This creates a bootstrap problem:

```text
Terraform needs the S3 bucket to initialize
                 ↓
the S3 bucket must first be created by Terraform
```

The bootstrap configuration solves this by using local state during its first execution and creating the remote state bucket. After that, `environments/development` and GitHub Actions can use the bucket.

## Scope

The bootstrap creates:

- one private S3 bucket for Terraform state;
- bucket versioning;
- server-side encryption;
- complete public-access blocking;
- an HTTPS-only bucket policy;
- a lifecycle rule for old state versions;
- native S3 state locking support.

It does **not** create the VPC, EC2 instance, ECR repositories, application security groups, or monitoring resources. Those belong to the environment and reusable modules.

## Execution model

```text
bootstrap (first apply runs locally)
    ↓ creates
S3 remote state bucket
    ↓ used by
environments/development
    ↓ creates
VPC, security, EC2, ECR and monitoring
```

The bootstrap is executed once during project setup and only rerun when its own resources change. It is not part of the normal application deployment workflow.

## Prerequisites

- Terraform CLI;
- AWS CLI;
- an AWS account with MFA enabled;
- non-root AWS credentials;
- permission to create and configure an S3 bucket;
- AWS Region `us-east-1`.

Confirm the active AWS identity before applying:

```bash
aws sts get-caller-identity
```

## First execution

Create the local variables file:

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Set the owner:

```hcl
aws_region = "us-east-1"
owner      = "your-name"
```

Initialize and validate:

```bash
terraform init
terraform fmt -check
terraform validate
```

Create and review a saved plan:

```bash
terraform plan -out=tfplan
terraform show tfplan
```

The plan should contain only S3 resources related to the Terraform backend. Apply the reviewed plan:

```bash
terraform apply tfplan
```

## Verify the result

Read the bucket name and backend configuration:

```bash
terraform output state_bucket_name
terraform output development_backend_configuration
```

Verify versioning:

```bash
BUCKET_NAME=$(terraform output -raw state_bucket_name)
aws s3api get-bucket-versioning --bucket "$BUCKET_NAME"
```

Expected status:

```json
{
  "Status": "Enabled"
}
```

Verify public-access blocking:

```bash
aws s3api get-public-access-block --bucket "$BUCKET_NAME"
```

All four public-access settings must be `true`.

## Configure the development backend

Use the bootstrap output in `terraform/environments/development/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "BUCKET_NAME_FROM_BOOTSTRAP_OUTPUT"
    key          = "environments/development/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Then initialize the environment:

```bash
cd ../environments/development
terraform init
```

Local Terraform and GitHub Actions must use this same bucket and backend key. They will then read and update the same state instead of creating independent infrastructure.

## Bootstrap state

The first bootstrap execution produces a local `terraform.tfstate` because the remote bucket does not exist yet. Do not commit this file.

After the bucket is created, the bootstrap state may be migrated into the same bucket under a separate key:

```text
bootstrap/terraform.tfstate
```

The development environment uses a different key:

```text
environments/development/terraform.tfstate
```

Never allow two configurations to share the same state key.

## Safety rules

- Never commit `terraform.tfstate`, `terraform.tfvars`, or `tfplan`.
- Never expose the state bucket publicly.
- Do not delete the bucket after the first deployment.
- Do not run bootstrap as part of every application deployment.
- Review every plan before applying it.
- Keep `prevent_destroy = true` on the state bucket.
- Use the same remote backend from local Terraform and GitHub Actions.

The state bucket is foundational infrastructure. Deleting it can remove the history Terraform needs to manage and recover the AWS environment.
