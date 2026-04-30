# ============================================================
# LECTURE 2.3 — Outputs
# ============================================================
#
# Outputs serve two purposes:
#   1. Interface for humans → shown after `terraform apply`
#   2. Interface for CI/CD → scripts read values via:
#      terraform output -raw vm_external_ip
#
# Think of outputs as your module's public API.
# ============================================================

# ── SIMPLE OUTPUT ─────────────────────────────────────────────
output "bucket_url" {
  description = "GCS bucket URL for TechFlow static assets"
  value       = google_storage_bucket.techflow_assets.url
}

# ── COMPUTED OUTPUT using reference chain ─────────────────────
output "vm_external_ip" {
  description = "External IP of TechFlow web VM (use in CI for smoke tests)"
  value       = google_compute_instance.techflow_web.network_interface[0].access_config[0].nat_ip
}

output "vm_internal_ip" {
  description = "Internal IP for private service communication"
  value       = google_compute_instance.techflow_web.network_interface[0].network_ip
}

# ── MAP OUTPUT — structured data for downstream systems ───────
output "deployment_summary" {
  description = "Complete deployment metadata — useful in CI logs"
  value = {
    environment  = var.environment
    machine_type = local.machine_type
    disk_size_gb = local.disk_size_gb
    db_tier      = local.db_tier
    bucket_name  = local.bucket_name
    vm_name      = google_compute_instance.techflow_web.name
    port_count   = local.port_count
  }
}

# ── CONDITIONAL OUTPUT ─────────────────────────────────────────
output "cdn_status" {
  description = "CDN enablement status (prod feature)"
  value       = var.enable_cdn ? "CDN enabled" : "CDN disabled (enable in prod)"
}

# ── FUNCTIONS DEMO OUTPUT — shows computed values ─────────────
output "computed_values_demo" {
  description = "Demonstrates function outputs (remove from production code)"
  value = {
    bucket_name    = local.bucket_name
    region_upper   = local.region_upper
    has_https_port = local.has_https
    all_ports_flat = local.all_ports_flat
    port_strings   = local.port_strings
    unique_ports   = local.unique_ports
  }
}
