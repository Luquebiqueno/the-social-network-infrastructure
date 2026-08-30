# Security Module

Creates the application EC2 security group, IAM role, and instance profile.

The security group exposes only ports 80 and 443 to configured CIDR blocks. Port 22 is not opened. Administrative access uses AWS Systems Manager Session Manager.

The EC2 role receives managed permissions for Session Manager and the CloudWatch Agent, plus a least-privilege inline policy for pulling images from the application ECR repositories.
