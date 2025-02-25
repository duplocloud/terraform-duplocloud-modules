
output "configurations" {
  value       = module.configurations
  description = "The configurations object."
}

output "release_id" {
  value       = local.release_id
  description = "The job id."
}

output "volumes" {
  value = local.volumes
}
