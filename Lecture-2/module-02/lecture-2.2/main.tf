# ============================================================
# LECTURE 2.2 — main.tf: Using All Variable Types
# ============================================================

# Merge user-provided labels with standard required labels
locals {
  common_labels = merge(var.resource_labels, {
    environment = var.environment
    project     = "techflow"
  })
}

# ============================================================
# GCS Bucket — uses map labels + string vars
# ============================================================
resource "google_storage_bucket" "techflow_assets" {
  name          = "techflow-assets-${var.environment}-${var.project_id}"
  location      = "US"
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true
  labels                      = local.common_labels
}

# ============================================================
# Demonstrates the sensitive variable is usable in resources
# (value is hidden in plan output, but used in the resource)
# ============================================================
resource "google_secret_manager_secret" "db_secret" {
  secret_id = "techflow-db-password-${var.environment}"

  replication {
    auto {}
  }

  labels = local.common_labels
}

resource "google_secret_manager_secret_version" "db_secret_version" {
  secret      = google_secret_manager_secret.db_secret.id
  secret_data = var.db_password # sensitive = true → hidden in plan output
}
