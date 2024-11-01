output "node_ami" {
  value = data.aws_ami.eks.id
}

output "nodes" {
  value = duplocloud_asg_profile.nodes
}
