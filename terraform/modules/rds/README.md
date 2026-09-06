# RDS Module

Creates the Amazon RDS for PostgreSQL instance used by The Social Network.

## Responsibilities

- creates a DB subnet group across the supplied subnets (private subnets are strongly recommended);
- creates a dedicated security group that only accepts PostgreSQL (port 5432) traffic from explicitly allowed security groups;
- creates a DB parameter group that forces SSL/TLS connections (`rds.force_ssl`);
- creates one `aws_db_instance` running PostgreSQL with encrypted storage;
- lets AWS manage the master password as a Secrets Manager secret (`manage_master_user_password`), so no credential is stored in Terraform state or configuration;
- creates a dedicated customer-managed KMS key (with rotation enabled) used to encrypt both the storage volume and the managed master password secret, unless `kms_key_id` and/or `master_user_secret_kms_key_id` are supplied explicitly.

The module does not create the VPC, subnets, or the security groups it references as allowed ingress sources. Those belong to their respective modules.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"

  environment                = "development"
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids
  allowed_security_group_ids = [module.security.ec2_security_group_id]

  database_name    = "the_social_network"
  master_username  = "tsn_admin"
  instance_class   = "db.t3.micro"
  allocated_storage = 20

  multi_az             = false
  deletion_protection  = false
  skip_final_snapshot  = true

  tags = {
    Project   = "the-social-network"
    ManagedBy = "terraform"
    Owner     = "your-name"
  }
}
```

## Retrieving the master password

The master password is never stored in Terraform state. Retrieve it from Secrets Manager using the secret ARN exposed by the `master_user_secret_arn` output:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw master_user_secret_arn)" \
  --query SecretString --output text | jq .
```

## Notes

- The instance is never publicly accessible (`publicly_accessible = false`). Applications must connect from within the VPC.
- Storage and the managed master password secret are encrypted with a dedicated customer-managed KMS key created by this module, unless `kms_key_id` / `master_user_secret_kms_key_id` are set. A customer-managed key is used instead of the account's default `aws/rds` and `aws/secretsmanager` keys because those may not exist yet in a fresh account/region, which makes `CreateDBInstance` fail with `KMSKeyNotAccessibleFault`.
- Creating and managing this KMS key requires `kms:*` permissions for the identity running Terraform (see `terraform/bootstrap`).
- `multi_az`, `deletion_protection`, and `skip_final_snapshot` default to values appropriate for a disposable development environment. Set `multi_az = true`, `deletion_protection = true`, and `skip_final_snapshot = false` for staging and production.
- RDS storage autoscaling is enabled by default via `max_allocated_storage`. Set it to `0` to disable.
- `enabled_cloudwatch_logs_exports` publishes PostgreSQL and upgrade logs to CloudWatch Logs.
