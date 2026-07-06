aws_region  = "ap-south-1"
environment = "dev"

vpc_cidr             = "10.10.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

# --- RDS: small, cheap, disposable ---
db_engine                  = "postgres"
db_engine_version          = "16.3"
db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
db_name                    = "hotel_bookings"
db_username                = "hotel_app"
db_password                = "changeme-dev-password"
db_backup_retention_period = 1
db_deletion_protection     = false
db_multi_az                = false
db_skip_final_snapshot     = true

# --- ECS: minimal sizing ---
container_image = "nginx:latest"
task_cpu        = "256"
task_memory     = "512"
desired_count   = 1
