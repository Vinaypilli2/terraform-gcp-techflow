variable "project_id" { type = string }
variable "region" { type = string; default = "us-central1" }
variable "zone" { type = string; default = "us-central1-a" }

variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "enable_cdn" {
  type        = bool
  description = "Enable CDN on the load balancer (prod only)"
  default     = false
}

variable "app_ports" {
  type        = list(number)
  description = "Ports the TechFlow app exposes"
  default     = [80, 443, 8080]
}

variable "team_tags" {
  type = map(string)
  default = {
    team       = "platform"
    managed-by = "terraform"
  }
}
