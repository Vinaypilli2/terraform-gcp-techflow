# ============================================================
# LECTURE 2.1 — Lifecycle Meta-Arguments
# ============================================================
#
# lifecycle controls HOW Terraform manages state transitions.
# These are not cosmetic — they directly affect production safety.
#
# 3 rules to know:
#   1. create_before_destroy → zero-downtime replacement
#   2. prevent_destroy       → safety guardrail for critical resources
#   3. ignore_changes        → co-existence with other systems
# ============================================================

variable "project_id" { type = string }
variable "region" { type = string; default = "us-central1" }
variable "env" { type = string; default = "dev" }

# ============================================================
# 1. create_before_destroy
# ============================================================
# Default Terraform behavior: destroy old → create new → DOWNTIME
# With this lifecycle: create new → verify → destroy old → NO DOWNTIME
#
# CRITICAL FOR: load balancers, VMs, anything handling live traffic
# ============================================================
resource "google_storage_bucket" "app_assets" {
  name          = "techflow-assets-${var.env}-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    lifecycle-demo = "create-before-destroy"
    env            = var.env
  }

  lifecycle {
    # When Terraform must replace this resource:
    # Step 1: Create the NEW bucket first
    # Step 2: Verify it exists
    # Step 3: THEN destroy the old one
    # Result: no gap in availability
    create_before_destroy = true
  }
}

# ============================================================
# 2. prevent_destroy
# ============================================================
# If anyone runs `terraform destroy` → Terraform will FAIL
# with: "Error: Instance cannot be destroyed"
#
# This is not optional in production — it is mandatory.
# ENABLE FOR: databases, critical state buckets, audit logs
# ============================================================
resource "google_storage_bucket" "state_bucket" {
  name          = "techflow-tfstate-${var.project_id}"
  location      = "US"
  force_destroy = false # never auto-delete objects in prod

  uniform_bucket_level_access = true

  versioning {
    enabled = true # enables rollback of state file
  }

  labels = {
    lifecycle-demo = "prevent-destroy"
    critical       = "true"
  }

  lifecycle {
    # DEMO: Try `terraform destroy` after apply → it will FAIL
    # This is your safety net.
    prevent_destroy = true
  }
}

# ============================================================
# 3. ignore_changes
# ============================================================
# Real-world scenario:
#   - Security team manages labels via Cloud Asset Inventory
#   - They add "compliance=pci" label to your VM
#   - Terraform next plan: "I see drift, I will remove it"
#   - That creates conflict between teams
#
# Solution: ignore_changes on fields managed by other systems
# ============================================================
resource "google_storage_bucket" "shared_bucket" {
  name          = "techflow-shared-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  # Terraform manages these labels initially
  labels = {
    managed-by = "terraform"
    env        = var.env
  }

  lifecycle {
    # Security / policy teams may add more labels externally.
    # Terraform will not try to "correct" those additions.
    ignore_changes = [labels]
  }
}

# ============================================================
# depends_on — EXPLICIT DEPENDENCY
# ============================================================
# Terraform auto-detects dependencies through references.
# BUT: if no reference exists in code, the graph is incomplete.
#
# Example: you enable an API, then create a resource that uses it.
# If the resource doesn't reference the API resource → Terraform
# might try to create the resource BEFORE the API is enabled → FAIL
# ============================================================
resource "google_project_service" "storage_api" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "explicit_dep_bucket" {
  name          = "techflow-explicit-dep-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  # No reference to google_project_service in any argument above.
  # Terraform would not know to wait. We add the explicit hint:
  depends_on = [google_project_service.storage_api]
}

# ============================================================
# OUTPUTS
# ============================================================
output "lifecycle_demo_buckets" {
  description = "Summary of lifecycle demo buckets"
  value = {
    app_assets   = google_storage_bucket.app_assets.url
    state_bucket = google_storage_bucket.state_bucket.url
    shared       = google_storage_bucket.shared_bucket.url
    explicit_dep = google_storage_bucket.explicit_dep_bucket.url
  }
}
