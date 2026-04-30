# ============================================================
# LECTURE 2.5 — Sample resource for CI to validate
# ============================================================
#
# DEMO: Intentionally break this file to show the CI catching it.
#
# Break 1 — formatting:
#   Change: name = "techflow-assets"
#   To:     name="techflow-assets"     (no spaces around =)
#   Then push → fmt check fails → CI catches it
#
# Break 2 — validation:
#   Change: location = "US"
#   To:     location = 12345           (wrong type: number vs string)
#   Then push → validate fails → CI catches it
#
# These are real errors that reach production without early CI.
# ============================================================

resource "google_storage_bucket" "techflow_assets" {
  name          = "techflow-assets-${var.environment}-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}
