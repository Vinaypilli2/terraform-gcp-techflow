# ============================================================
# LECTURE 2.4 — Outputs (Locals + Data Sources)
# ============================================================

output "vm_name" {
  value = google_compute_instance.techflow_web.name
}

output "vm_image_used" {
  description = "Exact image used (data source resolved at apply time)"
  value       = data.google_compute_image.debian.name
}

output "project_number" {
  description = "Numeric project ID from data source"
  value       = data.google_project.current.number
}

output "available_zones" {
  description = "Zones available in the configured region"
  value       = data.google_compute_zones.available.names
}

output "active_config" {
  description = "Effective env config resolved from locals"
  value       = local.config
}

output "vm_sa_email" {
  description = "Service account email for downstream IAM binding"
  value       = google_service_account.vm_sa.email
}
