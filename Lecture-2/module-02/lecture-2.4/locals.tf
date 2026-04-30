# ============================================================
# LECTURE 2.4 — Locals: The DRY Principle in Terraform
# ============================================================
#
# Locals = computed values
#   → derived from variables or other locals
#   → computed ONCE at plan time
#   → referenced EVERYWHERE in the config
#
# Without locals: you repeat complex expressions in every resource.
# One change = you edit every resource.
#
# With locals: you compute once, reference with a clean name.
# One change = you edit ONE locals block.
#
# This is the DRY principle (Don't Repeat Yourself) at the
# infrastructure configuration level.
# ============================================================

locals {
  # ── NAMING CONVENTION ─────────────────────────────────────────
  # Define once. Every resource uses the same prefix pattern.
  # Change the convention here → ALL resources update on next apply.
  name_prefix = "techflow-${var.environment}"

  # Specific resource names derived from prefix
  vm_name     = "${local.name_prefix}-web"
  bucket_name = "${local.name_prefix}-assets-${var.project_id}"
  sa_name     = "${local.name_prefix}-vm-sa"

  # ── STANDARD LABELS ───────────────────────────────────────────
  # Base labels applied to EVERY resource in TechFlow.
  # merge() → combine base with any caller-provided extras.
  # Extra labels override base labels if keys collide.
  base_labels = {
    project     = "techflow"
    environment = var.environment
    managed-by  = "terraform"
    team        = var.team
  }

  # Final labels used in every resource block
  # var.extra_labels allows callers to add without overriding base
  all_labels = merge(local.base_labels, var.extra_labels)

  # ── ENVIRONMENT-SPECIFIC CONFIGURATION ───────────────────────
  # One place to define ALL env differences.
  # Resources just look up their environment's values.
  env_config = {
    dev = {
      machine_type = "e2-micro"
      disk_gb      = 10
      disk_type    = "pd-balanced"
      replicas     = 1
    }
    staging = {
      machine_type = "e2-small"
      disk_gb      = 20
      disk_type    = "pd-balanced"
      replicas     = 2
    }
    prod = {
      machine_type = "e2-standard-4"
      disk_gb      = 50
      disk_type    = "pd-ssd"
      replicas     = 3
    }
  }

  # Look up current environment's config
  # Usage in resource: local.config.machine_type
  config = local.env_config[var.environment]
}
