# Terraform GitHub Actions

The workflows manage the Terraform `development` environment in AWS `us-east-1`.

## Workflows

- `terraform-plan.yml` runs formatting, initialization, validation, and planning for pull requests targeting `develop`.
- `terraform-apply.yml` creates a fresh plan and applies it after changes are merged into `develop`.

Both workflows use the same S3 state key:

```text
environments/development/terraform.tfstate
```

## Required repository variables

Configure these under **Settings → Secrets and variables → Actions → Variables**:

| Variable | Purpose |
| --- | --- |
| `AWS_ROLE_ARN` | IAM role assumed through GitHub OIDC |
| `TF_STATE_BUCKET` | S3 bucket created by the bootstrap |
| `TF_OWNER` | Value assigned to the Terraform `Owner` tag |

The role ARN and bucket name are identifiers, not credentials. Do not create permanent AWS access keys for the workflows.

## GitHub environment

Create an environment named `development` under **Settings → Environments**. Add a required reviewer if the repository plan supports environment protection and you want a manual approval before `apply`.

## OIDC trust

The AWS IAM role trust policy must accept tokens from this exact repository. Because the plan runs for pull requests and apply uses the `development` GitHub environment, allow only these subject forms:

```text
repo:OWNER/REPOSITORY:pull_request
repo:OWNER/REPOSITORY:environment:development
```

Do not use a trust policy that permits every GitHub repository.

## Branch protection

Protect `develop` and require:

- changes through pull requests;
- the `Validate and Plan` status check;
- resolved conversations;
- the branch to be up to date before merge.

## Apply behavior

The apply workflow does not reuse a plan artifact from the pull request. It creates a new plan from the merged commit and current remote state immediately before applying. This prevents a stale PR plan from being applied.

`terraform destroy` is intentionally not automated.
