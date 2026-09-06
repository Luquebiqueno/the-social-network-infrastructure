module "networking" {
  source = "../../modules/networking"

  name_prefix          = local.name_prefix
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix      = local.name_prefix
  environment      = var.environment
  repository_names = var.ecr_repository_names

  tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix         = local.name_prefix
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  allowed_http_cidrs  = var.allowed_http_cidrs
  allowed_https_cidrs = var.allowed_https_cidrs
  ecr_repository_arns = module.ecr.repository_arns

  tags = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix               = local.name_prefix
  environment               = var.environment
  subnet_id                 = module.networking.public_subnet_ids[0]
  security_group_ids        = [module.security.ec2_security_group_id]
  iam_instance_profile_name = module.security.ec2_instance_profile_name

  instance_type                 = var.instance_type
  root_volume_size              = var.root_volume_size
  associate_public_ip_address   = true
  enable_detailed_monitoring    = false
  enable_termination_protection = false

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix                = local.name_prefix
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids
  allowed_security_group_ids = [module.security.ec2_security_group_id]

  database_name     = var.db_name
  master_username   = var.db_master_username
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  apply_immediately       = true

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix        = local.name_prefix
  environment        = var.environment
  ec2_instance_id    = module.ec2.instance_id
  notification_email = var.alert_email

  tags = local.common_tags
}
