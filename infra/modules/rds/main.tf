locals {
  is_postgres = var.engine == "postgres"
  port        = local.is_postgres ? 5432 : 3306
  tags        = merge(var.tags, { Name = var.name_prefix })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnets"
  subnet_ids = var.private_subnet_ids

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow DB traffic only from ECS tasks"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${var.name_prefix}-rds-sg" })
}

resource "aws_security_group_rule" "rds_ingress_from_ecs" {
  # count (not for_each) because the security group ids are only known after
  # apply; for_each requires its keys to be known at plan time, count only
  # needs the list length, which is static here.
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
  description              = "DB access from ECS task security group"
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = local.is_postgres ? "postgres" : "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage      = var.allocated_storage
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = local.port
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Private only: no public access, only reachable from ECS security group above.
  publicly_accessible = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  multi_az                = var.multi_az

  tags = local.tags
}
