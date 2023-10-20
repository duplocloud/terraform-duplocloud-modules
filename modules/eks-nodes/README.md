# EKS HA Nodes  

Creates duplocloud EKS hosts for a tenant. This creates an HA setup on at least two zones. The min/max/count is actually multiplied by the amount of zones. So if you have 3 zones and you set min=1, max=3, count=2, you will get 6 hosts. 

## Example  

Here is a simple example used often.

```hcl
module "nodegroup" {
  source             = "duplocloud/components/duplocloud//modules/eks-nodes"
  version            = "0.0.5"
  tenant_id          = local.tenant_id
  capacity           = var.asg_capacity
  eks_version        = local.eks_version
  instance_count     = var.asg_instance_count
  min_instance_count = var.asg_min_instance_count
  max_instance_count = var.asg_max_instance_count
  os_disk_size       = var.asg_os_disk_size
}
```

## Testing  

Run the unit tests with: 
```sh
terraform test -filter=tests/unit.tftests.hcl
```

Run the integration tests with: 
```sh
terraform test -filter=tests/integration.tftests.hcl
```

## References  
  - [Duploclud Hosts](https://docs.duplocloud.com/docs/azure/use-cases/hosts-vms)
  - [Duplocloud ASG](https://docs.duplocloud.com/docs/aws/use-cases/auto-scaling/auto-scaling-groups)
