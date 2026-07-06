aws_region  = "ap-south-1"
environment = "prod"

vpc_cidr             = "10.20.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]

# --- RDS: larger, durable, protected ---
db_engine                  = "postgres"
db_engine_version          = "16.3"
db_instance_class          = "db.r6g.large"
db_allocated_storage       = 100
db_name                    = "hotel_bookings"
db_username                = "hotel_app"
db_password                = "changeme-use-secrets-manager-in-real-prod"
db_backup_retention_period = 30
db_deletion_protection     = true
db_multi_az                = true
db_skip_final_snapshot     = false

# --- ECS: production sizing, more replicas ---
container_image = "nginx:latest"
task_cpu        = "1024"
task_memory     = "2048"
desired_count   = 3
