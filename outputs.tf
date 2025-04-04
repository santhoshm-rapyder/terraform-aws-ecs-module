output "ecs_cluster_id" {
  description = "ID of the ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}


output "cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_asg_name" {
  value = aws_autoscaling_group.ecs_asg.id
}
