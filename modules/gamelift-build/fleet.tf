resource "awscc_gamelift_fleet" "this" {
  name              = awscc_gamelift_build.this.name
  build_id          = awscc_gamelift_build.this.id
  compute_type      = var.fleet_compute_type
  ec2_instance_type = var.fleet_ec2_instance_type
  ec2_inbound_permissions = var.fleet_ec2_inbound_permissions
  fleet_type        = var.fleet_type
  new_game_session_protection_policy = var.fleet_new_game_session_protection_policy
  instance_role_arn = local.tenant_role_arn
  locations = var.fleet_locations
  runtime_configuration = {
    server_processes = [
      {
        concurrent_executions = 1
        launch_path           = var.fleet_launch_path
        parameters            = var.fleet_parameters
      }
    ]
  }
}
