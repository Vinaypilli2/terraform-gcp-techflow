# ============================================================
# LECTURE 2.1 — Provider Version Pinning
# ============================================================
# The ~> operator is the "pessimistic constraint"
# ~> 5.0 means: allow 5.x.x, reject 6.0.0+
# This is your contract with the provider.
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

