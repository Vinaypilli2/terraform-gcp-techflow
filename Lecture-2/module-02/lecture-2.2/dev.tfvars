# ============================================================
# dev.tfvars — Development environment values
# ============================================================
# Usage: terraform apply -var-file=dev.tfvars
#
# ⚠️ NEVER commit files with real passwords or API keys to Git.
#    Add *.tfvars to .gitignore or use placeholder values here.
# ============================================================

project_id  = "your-gcp-project-id"
region      = "us-central1"
environment = "dev"
machine_type = "e2-micro"
vm_count    = 1

resource_labels = {
  managed-by  = "terraform"
  team        = "platform"
  cost-center = "engineering"
  tier        = "dev"
}

database_config = {
  tier                = "db-f1-micro"
  availability_type   = "ZONAL"
  disk_size_gb        = 10
  deletion_protection = false
}

# db_password and api_key → supply via env vars in CI:
#   export TF_VAR_db_password="..."
#   export TF_VAR_api_key="..."
# Never put real values in a .tfvars file that goes to Git.
