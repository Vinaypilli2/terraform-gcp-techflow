# ============================================================
# LECTURE 2.2 — Variables: Types, Validation, Sensitive
# ============================================================
#
# Variables are the API of your Terraform module.
# They define WHAT inputs your infrastructure accepts.
#
# Terraform enforces type checking at PLAN TIME — not runtime.
# Errors are caught BEFORE infrastructure changes.
# ============================================================

# ============================================================
# PRIMITIVE TYPES
# ============================================================

variable "project_id" {
  type        = string
  description = "GCP Project ID — get from console.cloud.google.com"
}

variable "region" {
  type        = string
  description = "GCP region for resource deployment"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Deployment environment"

  # ============================================================
  # VALIDATION — shifts error detection to plan stage
  # Without this: GCP API returns cryptic error after 30 seconds
  # With this: Terraform fails immediately with clear message
  # ============================================================
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "machine_type" {
  type        = string
  description = "GCE machine type for TechFlow VMs"
  default     = "e2-micro"

  # Prevent engineers from accidentally using expensive machines in dev
  validation {
    condition = contains([
      "e2-micro",
      "e2-small",
      "e2-medium",
      "e2-standard-2",
      "e2-standard-4"
    ], var.machine_type)
    error_message = "machine_type must be an approved e2 series type."
  }
}

variable "vm_count" {
  type        = number
  description = "Number of TechFlow web VMs to provision"
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10."
  }
}

# ============================================================
# COLLECTION TYPES
# ============================================================

variable "allowed_regions" {
  type        = list(string)
  description = "Regions where TechFlow may deploy resources"
  default     = ["us-central1", "us-east1", "us-west1"]
}

variable "resource_labels" {
  type        = map(string)
  description = "Labels applied to all TechFlow GCP resources"
  default = {
    managed-by  = "terraform"
    team        = "platform"
    cost-center = "engineering"
  }
}

# ============================================================
# COMPLEX OBJECT TYPE
# ============================================================
# Structured input — like a struct in code.
# Terraform validates every field and its type.
variable "database_config" {
  type = object({
    tier              = string
    availability_type = string
    disk_size_gb      = number
    deletion_protection = bool
  })
  description = "Cloud SQL instance configuration"
  default = {
    tier                = "db-f1-micro"
    availability_type   = "ZONAL"
    disk_size_gb        = 10
    deletion_protection = false
  }

  validation {
    condition     = var.database_config.disk_size_gb >= 10
    error_message = "Cloud SQL disk_size_gb must be at least 10 GB."
  }
}

# ============================================================
# SENSITIVE — hides from CLI output
# ============================================================
# ⚠️ IMPORTANT WARNING:
#   sensitive = true ONLY hides the value from terminal output.
#   The value is STILL STORED IN STATE FILE in plain text.
#
# This is NOT a security solution — it is a display filter.
# For real secrets: use GCP Secret Manager (Module 7).
# ============================================================
variable "db_password" {
  type        = string
  description = "Database password — use Secret Manager in production"
  sensitive   = true

  # Never provide a default for sensitive values.
  # Force the caller to supply it explicitly (via env var or CI secret).
}

variable "api_key" {
  type        = string
  description = "External API key for TechFlow integrations"
  sensitive   = true
}

# ============================================================
# VARIABLE PRECEDENCE ORDER (highest → lowest):
#
#   1. -var flag on CLI:        terraform apply -var="env=prod"
#   2. TF_VAR_ env vars:        export TF_VAR_environment=prod
#   3. .tfvars file:            terraform apply -var-file=prod.tfvars
#   4. default in variable {}:  default = "dev"
#
# Understanding this order prevents hard-to-debug CI/CD issues.
# ============================================================
