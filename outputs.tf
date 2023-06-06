output "instance_ip" {
  value = google_compute_instance.default[count.index].network_interface[0].access_config[0].nat_ip
}
