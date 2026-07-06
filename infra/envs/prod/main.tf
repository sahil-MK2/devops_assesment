locals {
  name_prefix = "hotel-${var.environment}"
  tags = {
    Project     = "hotel-devops-assessment"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  container_image = var.container_image
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory
  desired_count   = var.desired_count

  # DB_HOST is intentionally not wired from module.rds here to avoid a
  # module dependency cycle (RDS's security group only allows the ECS
  # task security group, and ECS would otherwise need RDS's endpoint).
  # In a real service, inject the endpoint via SSM/Secrets Manager instead
  # of a plain Terraform output, and reference the ecs module's security
  # group id (already available) from the rds module below.
  environment = {
    DB_NAME = var.db_name
  }

  tags = local.tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix    = local.name_prefix
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password

  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  multi_az                = var.db_multi_az
  skip_final_snapshot     = var.db_skip_final_snapshot

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  # RDS only accepts traffic from the ECS task security group - no public access.
  allowed_security_group_ids = [module.ecs.ecs_task_security_group_id]

  tags = local.tags
}
