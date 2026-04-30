# ============================================================
# LECTURE 2.1 — count vs for_each (PART B: for_each SOLUTION)
# ============================================================
#
# DEMO: Same scenario, but now remove "api" from the map.
# Watch Terraform delete ONLY the "api" bucket. Nothing else moves.
#
# WHY for_each IS SAFE:
#   Each resource is tracked by KEY ("web", "api", "worker")
#   Delete "api" key → only resource["api"] is destroyed
#   resource["web"] and resource["worker"] are untouched
#
# RULE: Use for_each whenever resources have distinct identity.
#       Use count ONLY for truly identical, interchangeable resources.
# ============================================================

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

# ============================================================
# MAP gives each resource a stable identity key
# ============================================================
variable "service_buckets" {
  type = map(object({
    location    = string
    description = string
  }))
  description = "Service buckets with named keys (safe for deletion)"
  default = {
    web = {
      location    = "US"
      description = "Static assets for web frontend"
    }
    api = {
      location    = "US"
      description = "API response cache and logs"
      # ⚠️ DEMO: Delete this block → ONLY this bucket is destroyed
    }
    worker = {
      location    = "US"
      description = "Background job artifacts"
    }
  }
}

# ============================================================
# for_each = map → resource["web"], resource["api"], resource["worker"]
# Identity is KEY-BASED, not position-based
# ============================================================
resource "google_storage_bucket" "services" {
  for_each = var.service_buckets

  name          = "techflow-${each.key}-${var.project_id}"
  location      = each.value.location
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    service     = each.key
    description = replace(each.value.description, " ", "-")
    managed-by  = "terraform"
    lecture     = "2-1"
  }
}

# ============================================================
# OUTPUT: Map output preserves key identity
# ============================================================
output "service_bucket_urls" {
  description = "Bucket URLs keyed by service name (not index)"
  value = {
    for k, v in google_storage_bucket.services : k => v.url
  }
}
