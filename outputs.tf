output "instance_ip" {
  value = null_resource.instance_ips[*].triggers.instance_index
}
output "instance_ip2" {
  value = "${google_compute_address.static-ip-address.address}"
}
