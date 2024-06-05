# ReTool Bastion Server  

DuploCloud creates all services as private. This means ReTool in the cloud can't directly access your database. To gain access to your database, you need a bastion server. This server will act as a bridge between ReTool and your private database. This setup can be used for any private resources, not just databases.

## Variables  

| Name | Description | Required | Default |  
|------|-------------|----------| ------- |  
| `tenant_id` | Tenant ID | true | |  
| `name` | Name of the bastion server | false | `retool-bastion` |  
| `capacity` | Capacity of the bastion server | false | `t3.small` |  
| `retool_public_key` | Public key of the ReTool server | true | |  

## Configuring Retool  

When adding a data source to Retool, notice there is an advanced section where you can configure an SSH tunnel. The bastion host will be the public IP address or the DNS name provided by AWS on this host. Download the provided public key on the ssh tunnel configuration, this is unique to your account. You will want to save this somewhere safe, maybe SSM Parameter Store, then reference it in your own Terraform module. 

The topology for this looks like this:  
```
(Retool) --ssh-tunnel--> (bastion server) --port-forward--> (RDS PostgreSQL)
```

## Example Usage

Here is a simple example of how to use this module.  
```hcl
module "retool-bastion" {
  source  = "duplocloud/components/duplocloud//modules/retool-bastion"
  version = "0.0.17"
  tenant_id = local.tenant_id
  retool_public_key = local.retool_public_key
}
```

Also see the [retool-bastion example](examples/retool-bastion) directory to see a fully working example.

## References

 - [Configure SSH tunneling for resources](https://docs.retool.com/data-sources/guides/ssh-tunnels)