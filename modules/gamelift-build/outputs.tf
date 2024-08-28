output "build_id" {
  value = awscc_gamelift_build.this.id
  
}

output "fleet_arn" {
  value = "arn:aws:gamelift:${local.region}:${local.account_id}:fleet/${awscc_gamelift_fleet.this.fleet_id}"
}

output "dm_fleet_arn" {
  value = "arn:aws:gamelift:${local.region}:${local.account_id}:fleet/${awscc_gamelift_fleet.this.fleet_id}"
}

output "squads_fleet_arn" {
  value = "arn:aws:gamelift:${local.region}:${local.account_id}:fleet/${awscc_gamelift_fleet.this.fleet_id}"
}