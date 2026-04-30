# ============================================================
# prod.tfvars — Production environment values
# ============================================================
# Usage: terraform apply -var-file=prod.tfvars
# ============================================================

project_id   = "your-gcp-project-id-prod"
region       = "us-central1"
environment  = "prod"
machine_type = "e2-standard-4"
vm_count     = 3

resource_labels = {
  managed-by  = "terraform"
  team        = "platform"
  cost-center = "engineering"
  tier        = "prod"
  compliance  = "required"
}

database_config = {
  tier                = "db-custom-2-4096"
  availability_type   = "REGIONAL"
  disk_size_gb        = 100
  deletion_protection = true
}

# db_password and api_key → injected by GitHub Actions secrets:
#   TF_VAR_db_password → from GitHub Actions secret DB_PASSWORD_PROD
#   TF_VAR_api_key     → from GitHub Actions secret API_KEY_PROD
