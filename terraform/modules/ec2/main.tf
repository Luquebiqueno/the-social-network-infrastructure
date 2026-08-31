resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address

  monitoring                           = var.enable_detailed_monitoring
  disable_api_termination              = var.enable_termination_protection
  instance_initiated_shutdown_behavior = "stop"

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    application_directory = var.application_directory
  })

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    encrypted             = true
    delete_on_termination = true
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    iops                  = var.root_volume_type == "gp3" ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null

    tags = merge(
      local.tags,
      { Name = "${local.instance_name}-root" }
    )
  }

  tags = local.tags
}
