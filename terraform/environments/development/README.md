# Development Environment

Terraform root module for The Social Network development infrastructure in AWS `us-east-1`.

## Responsibilities

This directory configures and composes the reusable modules. It does not implement their AWS resources directly.

```text
development
├── networking
├── ecr
├── security
├── ec2
└── monitoring
```

Each environment uses its own remote state. Local Terraform and GitHub Actions must initialize this directory with the same backend configuration.

## Dependency flow

```text
networking ──→ security ──→ ec2 ──→ monitoring
                    ↑
ecr ────────────────┘
```

- `networking` creates the VPC and subnets;
- `ecr` creates the Docker image repositories;
- `security` creates the EC2 security group, IAM role, and instance profile;
- `ec2` creates the Docker host;
- `monitoring` creates logs, alarms, and notifications.

## Prerequisites

- the bootstrap has been applied;
- the S3 state bucket exists;
- all referenced modules have been implemented;
- Terraform CLI and AWS CLI are installed;
- AWS authentication is configured for a non-root identity.

## Configure the backend

Copy the backend example:

```bash
cd terraform/environments/development
cp backend.hcl.example backend.hcl
```

Replace `BUCKET_NAME_FROM_BOOTSTRAP_OUTPUT` with:

```bash
terraform -chdir=../../bootstrap output -raw state_bucket_name
```

The resulting `backend.hcl` must resemble:

```hcl
bucket       = "tsn-terraform-state-ACCOUNT_ID-us-east-1"
key          = "environments/development/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

Initialize the remote backend:

```bash
terraform init -backend-config=backend.hcl
```

## Configure environment values

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set at least:

```hcl
owner = "your-name"
```

Do not commit `backend.hcl`, `terraform.tfvars`, state files, saved plans, credentials, secrets, or personal email addresses.

## Local validation

```bash
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```

Review the complete plan before applying it. Once CI/CD is enabled, normal infrastructure applies should run through GitHub Actions after an approved pull request.

## Apply before CI/CD exists

If the GitHub Actions deployment role and workflows do not exist yet, apply the reviewed plan locally:

```bash
terraform apply tfplan
```

Do not destroy these resources before enabling GitHub Actions. Both local Terraform and Actions will use the same remote state and continue managing the same infrastructure.

## Verify

```bash
terraform output
terraform state list
```

Start a Session Manager session after the EC2 instance is ready:

```bash
aws ssm start-session \
  --target "$(terraform output -raw ec2_instance_id)" \
  --region us-east-1
```

## Module order

All referenced modules are implemented. Terraform derives their dependency order from input and output references:

1. `networking` and `ecr` can be created independently;
2. `security` uses outputs from both;
3. `ec2` uses networking and security outputs;
4. `monitoring` uses the EC2 instance ID.
