
output "alb_arn" {
  description = "The ARN of the ALB."
  value       = duplocloud_aws_load_balancer.standalone.arn
}

output "listener_arn" {
  description = "The https listener ARN for target groups to connect with."
  value       = duplocloud_aws_load_balancer_listener.https.arn
}
