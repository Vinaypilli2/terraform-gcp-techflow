# ============================================================
# LECTURE 2.4 — main.tf: Locals + Data Sources in Action
# ============================================================
#
# THE PATTERN:
#   data source → fetches dynamic info from GCP at plan time
#   locals      → computes derived values from data + variables
#   resource    → uses clean, named local references
#
# Result: clean resources with no embedded complex logic
# ============================================================

# ============================================================
# VM — uses data source image + locals for all config values
# ============================================================
resource "google_compute_instance" "techflow_web" {
  name         = local.vm_name                # from locals.tf
  machine_type = local.config.machine_type    # env-specific from locals.tf
  zone         = data.google_compute_zones.available.names[0] # first available zone

  boot_disk {
    initialize_params {
      # data source → always latest image, never outdated
      image = data.google_compute_image.debian.self_link
      size  = local.config.disk_gb       # env-specific disk size
      type  = local.config.disk_type     # pd-balanced (dev) / pd-ssd (prod)
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # data.google_project.current.number gives us the numeric project ID
  metadata = {
    project-number = data.google_project.current.number
    environment    = var.environment
    enable-oslogin = "TRUE"
  }

  labels = local.all_labels # from locals.tf — DRY labels across all resources
}

# ============================================================
# GCS Bucket — same pattern: locals for name + labels
# ============================================================
resource "google_storage_bucket" "techflow_assets" {
  name          = local.bucket_name  # from locals.tf
  location      = "US"
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true
  labels                      = local.all_labels

  versioning {
    enabled = var.environment == "prod"
  }
}

# ============================================================
# Service Account — name from locals, email as output
# ============================================================
resource "google_service_account" "vm_sa" {
  account_id   = local.sa_name        # from locals.tf
  display_name = "TechFlow VM SA (${var.environment})"
}
