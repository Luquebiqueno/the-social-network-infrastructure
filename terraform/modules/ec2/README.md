# EC2 Module

Creates the EC2 host used to run The Social Network containers.

## Responsibilities

- resolves the latest Ubuntu Server 24.04 LTS amd64 AMI;
- creates one EC2 instance;
- creates an encrypted root EBS volume;
- enforces IMDSv2;
- attaches existing security groups and an IAM instance profile;
- installs Docker Engine and Docker Compose;
- prepares `/opt/the-social-network` for deployments.

The module does not create networking, security groups, IAM roles, ECR repositories, or CloudWatch alarms. Those belong to their respective modules.

## Usage

```hcl
module "ec2" {
  source = "../../modules/ec2"

  environment               = "development"
  subnet_id                 = module.networking.public_subnet_ids[0]
  security_group_ids        = [module.security.ec2_security_group_id]
  iam_instance_profile_name = module.security.ec2_instance_profile_name

  instance_type                      = "t3.micro"
  root_volume_size                   = 20
  associate_public_ip_address        = true
  enable_detailed_monitoring         = false
  enable_termination_protection      = false

  tags = {
    Project   = "the-social-network"
    ManagedBy = "terraform"
    Owner     = "your-name"
  }
}
```

## Administrative access

Do not expose SSH to `0.0.0.0/0`. Attach an instance profile with `AmazonSSMManagedInstanceCore` and connect through AWS Systems Manager Session Manager:

```bash
aws ssm start-session --target INSTANCE_ID --region us-east-1
```

## Notes

- The default public IP is appropriate only for the initial development environment.
- Production should place EC2 instances behind an Application Load Balancer and normally avoid direct public addressing.
- Changing user data replaces the instance because `user_data_replace_on_change` is enabled.
- Detailed monitoring is disabled by default to control cost.
- The module does not store credentials or application secrets.
