output "app_instance_name" {
  description = "App instance registered in the self-managed instance group."
  value       = google_compute_instance.app.name
}

output "app_external_ip" {
  description = "Static external IPv4 address assigned to the app instance."
  value       = google_compute_address.app.address
}

output "monitor_internal_ip" {
  description = "Private IP address for the monitor instance."
  value       = google_compute_instance.monitor.network_interface[0].network_ip
}

output "monitor_external_ip" {
  description = "Static external IPv4 address assigned to the monitor instance."
  value       = google_compute_address.monitor.address
}