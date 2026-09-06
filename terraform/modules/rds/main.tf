locals {
  resource_prefix        = "${var.name_prefix}-${var.environment}"
  parameter_group_family = "postgres${split(".", var.engine_version)[0]}"

  create_kms_key                = var.kms_key_id == null || var.master_user_secret_kms_key_id == null
  storage_kms_key_id            = coalesce(var.kms_key_id, try(aws_kms_key.rds[0].arn, null))
  master_user_secret_kms_key_id = coalesce(var.master_user_secret_kms_key_id, try(aws_kms_key.rds[0].arn, null))
}

resource "aws_kms_key" "rds" {
  count = local.create_kms_key ? 1 : 0

  description             = "Encrypts the ${local.resource_prefix} PostgreSQL RDS instance storage and its managed master password secret"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, { Name = "${local.resource_prefix}-rds-kms" })
}

resource "aws_kms_alias" "rds" {
  count = local.create_kms_key ? 1 : 0

  name          = "alias/${local.resource_prefix}-rds"
  target_key_id = aws_kms_key.rds[0].key_id
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.resource_prefix}-postgres"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${local.resource_prefix}-postgres-subnet-group" })
}

resource "aws_security_group" "rds" {
  name        = "${local.resource_prefix}-rds-sg"
  description = "Controls access to the PostgreSQL RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${local.resource_prefix}-rds-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "postgresql" {
  for_each = {
    for index, security_group_id in var.allowed_security_group_ids :
    tostring(index) => security_group_id
  }

  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = each.value
  description                  = "PostgreSQL access from application security group"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.rds.id
  description       = "Required outbound access for RDS management traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.resource_prefix}-postgres"
  family = local.parameter_group_family

  parameter {
    name         = "rds.force_ssl"
    value        = var.force_ssl ? "1" : "0"
    apply_method = "immediate"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "this" {
  identifier = "${local.resource_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage == 0 ? null : var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = local.storage_kms_key_id

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password   = true
  master_user_secret_kms_key_id = local.master_user_secret_kms_key_id

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.resource_prefix}-postgres-final"
  copy_tags_to_snapshot     = true

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, { Name = "${local.resource_prefix}-postgres" })
}
