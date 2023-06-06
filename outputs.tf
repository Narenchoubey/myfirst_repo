output "instance_ip" {
  value = null_resource.instance_ips[*].triggers.instance_index
}
