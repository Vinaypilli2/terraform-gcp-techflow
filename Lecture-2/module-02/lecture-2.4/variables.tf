variable "project_id" { type = string }
variable "region" { type = string; default = "us-central1" }
variable "zone" { type = string; default = "us-central1-a" }

variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "team" {
  type    = string
  default = "platform"
}

variable "extra_labels" {
  type        = map(string)
  description = "Additional labels to merge with standard labels"
  default     = {}
}
