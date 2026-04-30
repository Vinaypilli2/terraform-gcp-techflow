# ============================================================
# LECTURE 2.3 — Outputs, Conditionals & Functions
# ============================================================
#
# Conditionals make Terraform declarative — you describe state
# based on conditions. You are not writing steps, you are
# describing WHAT should exist.
#
# Functions transform values dynamically — without them,
# Terraform would be a static config file.
# ============================================================

# ============================================================
# LOCALS — compute complex values once, use everywhere
# (previews concept from Lecture 2.4, used here for functions demo)
# ============================================================
locals {
  # ── STRING FUNCTIONS ────────────────────────────────────────
  # format(): printf-style string composition
  bucket_name = format("techflow-%s-%s", var.environment, var.project_id)

  # upper() / lower() / trimspace()
  region_upper = upper(var.region)           # "US-CENTRAL1"
  env_lower    = lower(var.environment)      # always lowercase

  # replace(): useful for sanitizing names (GCP doesn't allow underscores)
  safe_project = replace(var.project_id, "_", "-")

  # ── COLLECTION FUNCTIONS ────────────────────────────────────
  # merge(): combine maps without repetition
  all_labels = merge(var.team_tags, {
    environment = var.environment
    project     = "techflow"
  })

  # length(): count items in a list
  port_count = length(var.app_ports) # → 3

  # contains(): check list membership
  has_https = contains(var.app_ports, 443) # → true

  # flatten(): collapses nested lists into one
  all_ports_flat = flatten([var.app_ports, [9090, 9091]])

  # ── CONDITIONAL EXPRESSIONS ─────────────────────────────────
  # Ternary: condition ? value_if_true : value_if_false
  # This is the heart of environment-aware configuration.
  machine_type = var.environment == "prod" ? "e2-standard-4" : "e2-micro"
  vm_count     = var.environment == "prod" ? 3 : 1
  disk_size_gb = var.environment == "prod" ? 50 : 10

  # Nested conditional for 3 environments
  db_tier = var.environment == "prod" ? "db-custom-2-4096" : (
    var.environment == "staging" ? "db-g1-small" : "db-f1-micro"
  )

  # coalesce(): return first non-null, non-empty value
  # Useful for optional overrides
  effective_region = coalesce(var.region, "us-central1")

  # ── TYPE CONVERSION FUNCTIONS ────────────────────────────────
  port_strings = [for p in var.app_ports : tostring(p)]   # [number] → [string]
  unique_ports = toset(var.app_ports)                      # list → set (removes dupes)
}

# ============================================================
# RESOURCE: Uses conditional local values
# ============================================================
resource "google_storage_bucket" "techflow_assets" {
  name          = local.bucket_name
  location      = "US"
  force_destroy = var.environment != "prod" # conditional inline

  uniform_bucket_level_access = true
  labels                      = local.all_labels

  # Versioning only in prod and staging
  dynamic "versioning" {
    for_each = var.environment != "dev" ? [1] : []
    content {
      enabled = true
    }
  }
}

resource "google_compute_instance" "techflow_web" {
  # conditional machine size based on environment
  name         = "techflow-web-${var.environment}"
  machine_type = local.machine_type  # e2-micro (dev) / e2-standard-4 (prod)
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = local.disk_size_gb    # 10 (dev) / 50 (prod)
      type  = var.environment == "prod" ? "pd-ssd" : "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  labels = local.all_labels

  metadata = {
    enable-oslogin = "TRUE"
  }
}
