locals {
  instance_name = "${var.name_prefix}-${var.environment}-ec2"
  ami_id        = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.ubuntu_ami[0].value

  tags = merge(
    var.tags,
    {
      Name        = local.instance_name
      Environment = var.environment
    }
  )
}
