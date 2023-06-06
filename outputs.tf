output "instance_ip" {
  value = "${google_compute_address.static-ip-address.*.address}"
}
