output "instance_ip" {
  value = google_compute_instance.default.network_interface[count.index].access_config[count.index].nat_ip
} 
