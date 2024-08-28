resource "awscc_gamelift_fleet" "this" {
  name              = awscc_gamelift_build.this.name
  build_id          = awscc_gamelift_build.this.id
  compute_type      = "EC2"
  ec2_instance_type = "c5.large"
  ec2_inbound_permissions = [{
    from_port = 7777
    to_port = 7777
    ip_range= "0.0.0.0/0"
    protocol= "UDP"
  }]
  fleet_type        = "ON_DEMAND"
  new_game_session_protection_policy = "FullProtection"
  instance_role_arn = local.tenant_role_arn
  runtime_configuration = {
    server_processes = [
      {
        concurrent_executions = 1
        launch_path           = "/local/game/Gibroski/Binaries/Linux/GibroskiServer"
        parameters            = "-nosteam -GameModeType=Arcade"
      }
    ]
  }
}
