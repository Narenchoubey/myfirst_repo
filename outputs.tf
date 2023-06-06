output "instance_ip" {
  value = google_compute_instance.default.network_interface[count.index + 2].access_config[count.index + 2].nat_ip
} 
