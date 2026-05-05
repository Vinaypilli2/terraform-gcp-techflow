# Module 03 — Reusable Modules

> **Course:** Terraform for DevOps Jobs — GCP + CI/CD  
> **Module:** 03 — Reusable Modules  
> **Lectures:** 3.1 → 3.5

---

## 📁 Final Folder Structure (Lecture 3.5)

```
lecture-3.5/
├── modules/
│   ├── networking/
│   │   ├── main.tf       ← VPC, subnet, Cloud Router, NAT, firewall rules
│   │   ├── variables.tf  ← module API
│   │   └── outputs.tf    ← network_self_link, subnet_self_link (consumed by compute)
│   ├── compute/
│   │   ├── main.tf       ← VMs with for_each
│   │   ├── variables.tf  ← accepts network links from networking module
│   │   └── outputs.tf    ← internal_ips, external_ips, vm_names
│   └── iam/
│       ├── main.tf       ← service accounts + least-privilege bindings
│       ├── variables.tf
│       └── outputs.tf    ← vm_sa_email (consumed by compute)
└── environments/
    ├── dev/
    │   ├── main.tf       ← CALLS all 3 modules, wires outputs → inputs
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── dev.tfvars
    └── prod/
        ├── main.tf       ← same modules, different values
        ├── variables.tf
        └── prod.tfvars
```

---

## 🔗 Module Wiring Diagram

```
IAM module
  └── output: vm_sa_email
              │
              ▼
Networking module          Compute module
  └── output: network_self_link ──► input: network_self_link
  └── output: subnet_self_link  ──► input: subnet_self_link
                                    input: service_account_email ◄── vm_sa_email
```

---

## 🚀 How to Run

```bash
cd lecture-3.5/environments/dev

terraform init
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

# Show outputs
terraform output deployment_summary
terraform output vm_internal_ips
```

```bash
# Prod (same commands, different folder)
cd lecture-3.5/environments/prod
terraform init
terraform apply -var-file=prod.tfvars
```

---

## 🎯 Key Takeaways Per Lecture

| Lecture | Key Concept |
|---------|-------------|
| 3.1 | Modules = write once, reuse everywhere |
| 3.2 | Module structure: variables.tf (API) + main.tf + outputs.tf |
| 3.3 | Networking module: VPC + subnet + NAT + firewall |
| 3.4 | for_each in modules: multiple named resources safely |
| 3.5 | Composition: modules call other modules via output→input wiring |
