resource "awscc_gamelift_fleet" "this" {
  name                               = awscc_gamelift_build.this.name
  build_id                           = awscc_gamelift_build.this.id
  compute_type                       = var.fleet.compute_type
  ec2_instance_type                  = var.fleet.ec2_instance_type
  ec2_inbound_permissions            = var.fleet.ec2_inbound_permissions
  fleet_type                         = var.fleet.type
  new_game_session_protection_policy = var.fleet.new_game_session_protection_policy
  locations                          = var.fleet.locations
  instance_role_arn                  = local.tenant_role_arn
  runtime_configuration = {
    server_processes = [
      {
        concurrent_executions = 1
        launch_path           = var.fleet.launch_path
        parameters            = var.fleet.parameters
      }
    ]
  }
}
