data "aws_ssm_parameter" "ubuntu_ami" {
  count = var.ami_id == null ? 1 : 0

  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}
