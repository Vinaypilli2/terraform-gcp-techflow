# ============================================================
# LECTURE 2.1 — count vs for_each (PART A: count PROBLEM)
# ============================================================
#
# DEMO: Run this first. Then remove "api" from the list.
# Watch Terraform destroy the WRONG resources.
#
# THIS IS THE PROBLEM WITH count:
#   count uses positional index → index 0, 1, 2
#   Delete the middle item ("api") → Terraform renumbers
#   resource[1] is now "worker" but Terraform sees it as changed
#   Result: destroys and recreates resources unexpectedly
# ============================================================

variable "bucket_names_count" {
  type        = list(string)
  description = "Bucket names using count (DANGEROUS for deletions)"
  default     = ["web", "api", "worker"]

  # ⚠️ DEMO: After apply, remove "api" → watch what breaks
  # default = ["web", "worker"]
}

resource "google_storage_bucket" "count_demo" {
  count = length(var.bucket_names_count)

  name          = "${var.bucket_names_count[count.index]}-bucket-${var.project_id}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    demo       = "count-problem"
    lecture    = "2-1"
    index      = tostring(count.index)
  }
}

# ============================================================
# OUTPUT: Show which resources were created
# ============================================================
output "count_bucket_names" {
  description = "Buckets created with count (notice index-based names)"
  value       = [for b in google_storage_bucket.count_demo : b.name]
}
