# only do plans here
run "validate_job_defaults" {
  command = plan
  variables {
    tenant = "dev01"
    name   = "myapp"
    command = ["npm"]
    jobs = [{
      name = "prerelease"
      event = "before-update"
      args = ["run", "db:migrate"]
      wait = true
      enabled = true
    }]
  }

  # make sure a before update job was created and the resource count is one
  assert {
    condition = length(duplocloud_k8s_job.before_update) == 1
    error_message = "The before update job was not created."
  }

  # make sure the command on the before update job is set to the default command
  assert {
    condition = duplocloud_k8s_job.before_update["prerelease"].spec[0].template[0].spec[0].container[0].command == var.command
    error_message = "The command on the before update job was not set to the default command."
  }

}
