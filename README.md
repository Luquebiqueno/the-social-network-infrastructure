# The Social Network Infrastructure

Terraform infrastructure for **The Social Network** on AWS.

The project uses Amazon EC2 as its primary compute service. The backend, frontend, and Keycloak will run as Docker containers.

## Repository structure

```text
the-social-network-infrastructure/
├── README.md
├── .gitignore
├── terraform/
│   ├── bootstrap/
│   ├── environments/
│   │   └── development/
│   └── modules/
│       ├── networking/
│       ├── security/
│       ├── ec2/
│       ├── ecr/
│       └── monitoring/
└── .github/
    └── workflows/
        ├── terraform-plan.yml
        └── terraform-apply.yml
```

## Directories

### `terraform/bootstrap`

Creates the resources Terraform needs before provisioning the application infrastructure, primarily the S3 backend used to store and lock the remote state.

Bootstrap starts with a local state and is run only when setting up or changing the state backend.

### `terraform/environments/development`

Defines the development environment. It configures and connects the infrastructure modules with environment-specific values such as the AWS Region, CIDR ranges, and EC2 instance type.

This environment has its own remote state and must not contain secrets.

### `terraform/modules/networking`

Creates networking resources:

- VPC;
- public and private subnets;
- Internet Gateway;
- route tables and associations.

### `terraform/modules/security`

Creates access-control resources:

- security groups;
- IAM roles and policies;
- EC2 instance profile;
- Systems Manager permissions.

SSH must not be exposed to `0.0.0.0/0`. Administrative access should use AWS Systems Manager Session Manager.

### `terraform/modules/ec2`

Creates the EC2 instance that runs the application containers, including its encrypted EBS volume, IAM instance profile, security groups, IMDSv2 configuration, and bootstrap script.

### `terraform/modules/ecr`

Creates the Amazon ECR repositories used to store Docker images for the backend, frontend, and optional custom Keycloak image.

### `terraform/modules/monitoring`

Creates CloudWatch log groups, alarms, dashboards, and notification resources required to monitor the EC2 instance and applications.

### `.github/workflows`

Contains the infrastructure CI/CD workflows:

- `terraform-plan.yml` validates changes and generates a plan for pull requests;
- `terraform-apply.yml` applies approved changes after they are merged.

GitHub Actions should authenticate to AWS through OIDC. Long-lived AWS access keys must not be stored in GitHub Secrets.

## Environments and modules

An environment assembles modules and supplies their configuration:

```text
development environment
├── networking
├── security
├── ec2
├── ecr
└── monitoring
```

Start with resources directly inside `environments/development`. Extract a module only when a clear reusable boundary exists. Avoid creating empty or overly generic modules upfront.

## Prerequisites

- Terraform CLI;
- AWS CLI;
- an AWS account with MFA enabled;
- authenticated access to AWS;
- AWS Region `eu-west-1`.

## Bootstrap

```bash
cd terraform/bootstrap
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

After the backend exists, initialize the development environment:

```bash
cd ../environments/development
terraform init
```

## Development workflow

Format and validate the configuration:

```bash
terraform fmt -recursive
terraform validate
```

Review the proposed changes:

```bash
terraform plan -out=tfplan
```

Apply the reviewed plan:

```bash
terraform apply tfplan
```

Inspect outputs:

```bash
terraform output
```

## Safety rules

- Always review `terraform plan` before applying changes.
- Never commit state files, plan files, credentials, or secrets.
- Commit `.terraform.lock.hcl` to keep provider versions reproducible.
- Use remote state with encryption, versioning, and locking.
- Use IAM roles and temporary credentials instead of access keys.
- Protect the default branch and require pull requests.
- Use consistent `Project`, `Environment`, `ManagedBy`, and `Owner` tags.
- Run `terraform destroy` only against an explicitly selected non-production environment.

## Initial scope

The first infrastructure release provisions:

- one custom VPC;
- public and private subnets;
- one Ubuntu EC2 instance;
- one encrypted gp3 EBS volume;
- IAM access for Session Manager;
- application security groups;
- ECR repositories;
- basic CloudWatch monitoring.

RDS, Application Load Balancer, Auto Scaling, CloudFront, WAF, ElastiCache, and SQS will be introduced only when the application requires them.
