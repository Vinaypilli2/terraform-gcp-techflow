# ============================================================
# LECTURE 2.4 — Data Sources: Reading Without Managing
# ============================================================
#
# A data source does NOT create infrastructure.
# It READS existing infrastructure at plan time.
#
# Critical distinction:
#   resource → Terraform owns it (creates, updates, destroys)
#   data     → Terraform reads it (never modifies)
#
# Reference syntax: data.TYPE.NAME.attribute
# ============================================================

# ── ALWAYS-FRESH DEBIAN IMAGE ─────────────────────────────────
# Problem with hardcoding: "debian-cloud/debian-11" is a family,
# but if you hardcode a specific image ID it becomes outdated.
#
# Data source: always resolves to the LATEST image in the family.
# Result: security patches picked up automatically on next apply.
data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}

# ── CURRENT PROJECT METADATA ──────────────────────────────────
# Useful when you need project number (not just ID).
# GCP sometimes requires project NUMBER, not project ID.
data "google_project" "current" {
  # No arguments needed — reads the provider's configured project
}

# ── AVAILABLE ZONES IN REGION ─────────────────────────────────
# Don't hardcode zones. Query what's actually available.
# Resilient to GCP adding or retiring zones.
data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

# ── EXISTING SECRET VERSION (READ-ONLY) ───────────────────────
# You manage the secret in Secret Manager (manually or via another module).
# This module READS the latest version without managing it.
# Pattern: secrets are managed by security team → infra team reads them.
data "google_secret_manager_secret_version" "db_password" {
  secret = "techflow-db-password-${var.environment}"
  # version = "latest" is the default
}
