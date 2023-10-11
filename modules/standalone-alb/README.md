# Standalone ALB  

Creates a standalone ALB with a static health check at `/`. This is meant to be provisioned before any services are available in an `aws-services` root module. Once provisioned each needed service can be loaded up with a target group and attached to this. Ideally the service module will output this listener arn as it is needed to attach to a specific services target group. 
