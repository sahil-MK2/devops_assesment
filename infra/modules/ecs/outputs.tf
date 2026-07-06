output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "ecs_task_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.this.name
}
