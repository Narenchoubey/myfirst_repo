output "google_compute_address" {
  value = "${google_compute_address.static-ip-address.*.address}"
}
