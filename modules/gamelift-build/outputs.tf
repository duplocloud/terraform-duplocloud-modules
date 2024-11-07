output "build_id" {
  value = awscc_gamelift_build.this.id
}

output "fleet_id" {
  value = awscc_gamelift_fleet.this.fleet_id
}
