# Module 02 — Advanced Configuration

> **Course:** Terraform for DevOps Jobs — GCP + CI/CD  
> **Module:** 02 — Advanced Configuration  
> **Lectures:** 2.1 → 2.5

---

## 📁 Folder Structure

```
module-02/
├── .gitignore                    ← Add BEFORE first commit
│
├── lecture-2.1/                  ← Providers, Resources & Meta-Arguments
│   ├── provider.tf               ← Version pinning + lock file demo
│   ├── variables.tf
│   ├── count-demo/
│   │   └── main.tf               ← Shows WHY count is dangerous
│   ├── for_each-demo/
│   │   └── main.tf               ← Shows WHY for_each is safe
│   └── lifecycle-demo/
│       └── main.tf               ← create_before_destroy, prevent_destroy, ignore_changes
│
├── lecture-2.2/                  ← Variables: Types, Validation, Sensitive
│   ├── provider.tf
│   ├── variables.tf              ← All types + validation + sensitive
│   ├── main.tf
│   ├── dev.tfvars
│   └── prod.tfvars
│
├── lecture-2.3/                  ← Outputs, Conditionals & Functions
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf                   ← All string/collection/type functions + conditionals
│   └── outputs.tf                ← Outputs as interface for CI/CD
│
├── lecture-2.4/                  ← Locals & Data Sources
│   ├── provider.tf
│   ├── variables.tf
│   ├── locals.tf                 ← DRY naming, labels, env config map
│   ├── data.tf                   ← Image, project, zones, secret data sources
│   ├── main.tf                   ← Uses locals + data sources throughout
│   └── outputs.tf
│
└── lecture-2.5/                  ← Early CI — fmt + validate
    ├── provider.tf
    ├── variables.tf
    ├── main.tf                   ← Sample resource with intentional break points
    └── .github/
        └── workflows/
            └── pr-checks.yml     ← GitHub Actions: fmt + validate on every PR
```

---

## 🚀 How to Use Each Lecture

### Lecture 2.1 — count vs for_each Demo

```bash
cd lecture-2.1/count-demo
terraform init
terraform apply -var="project_id=YOUR_PROJECT"

# Then edit variable to remove "api" from the list
# Run: terraform plan → watch wrong resources get destroyed
```

```bash
cd lecture-2.1/for_each-demo
terraform init
terraform apply -var="project_id=YOUR_PROJECT"

# Then remove "api" from the map
# Run: terraform plan → only "api" is destroyed
```

```bash
cd lecture-2.1/lifecycle-demo
terraform init
terraform apply -var="project_id=YOUR_PROJECT"

# Test prevent_destroy: terraform destroy → should FAIL on state_bucket
```

---

### Lecture 2.2 — Variables

```bash
cd lecture-2.2
terraform init

# Dev environment
terraform apply -var-file=dev.tfvars \
  -var="db_password=dev-test-password" \
  -var="api_key=dev-api-key"

# Prod environment
terraform apply -var-file=prod.tfvars \
  -var="db_password=$PROD_DB_PASSWORD" \
  -var="api_key=$PROD_API_KEY"

# Intentional validation failure:
terraform plan -var="environment=invalid" -var="project_id=YOUR_PROJECT"
# → Should fail with "environment must be one of: dev, staging, prod"
```

---

### Lecture 2.3 — Functions & Conditionals

```bash
cd lecture-2.3
terraform init

# Dev: e2-micro, 10GB disk, no versioning
terraform apply -var="project_id=YOUR_PROJECT" -var="environment=dev"

# Prod: e2-standard-4, 50GB pd-ssd, versioning enabled
terraform apply -var="project_id=YOUR_PROJECT" -var="environment=prod"

# Test functions in console:
terraform console
> format("techflow-%s-%s", "dev", "my-project")
> contains(["dev","staging","prod"], "prod")
> merge({a="1"}, {b="2"})
> flatten([[80, 443], [8080]])
```

---

### Lecture 2.4 — Locals & Data Sources

```bash
cd lecture-2.4
terraform init

# Note: data.google_secret_manager_secret_version requires the secret
# to exist first. Comment it out for initial demo.

terraform apply -var="project_id=YOUR_PROJECT" -var="environment=dev"

# Show outputs
terraform output available_zones
terraform output active_config
terraform output vm_image_used   # proves data source resolved to latest image
```

---

### Lecture 2.5 — CI Setup

```bash
# 1. Push the .github/workflows/pr-checks.yml file to your repo
# 2. Create a feature branch and make a change to any .tf file
# 3. Open a Pull Request

# To demo fmt failure:
cd lecture-2.5
# Edit main.tf: remove spaces around = signs
# Push → CI catches it

# To demo validate failure:
# Edit main.tf: change location = "US" to location = 12345
# Push → CI catches it

# To fix locally:
terraform fmt -recursive
terraform init -backend=false && terraform validate
```

---

## 🎯 Key Takeaways

| Lecture | Key Rule |
|---------|----------|
| 2.1 | Use `for_each` over `count` whenever resources have names |
| 2.1 | `prevent_destroy = true` on every production database |
| 2.2 | Validation blocks catch errors at plan time, not at API time |
| 2.2 | `sensitive = true` hides from output, NOT from state file |
| 2.3 | Conditionals make one codebase serve all environments |
| 2.4 | `locals {}` = DRY principle for configuration |
| 2.4 | Data sources always fetch latest — no hardcoded image IDs |
| 2.5 | Add CI in Module 2, not Module 8 — fix problems early |
