# AWS Control Tower Terraform

Terraform configuration to bootstrap AWS Organizations, organizational units, AWS accounts, and an AWS Control Tower landing zone.

## Prerequisites

- Terraform `>= 1.9.0`
- AWS provider `~> 6.0`
- AWS credentials for the **management account** with permissions for:
  - AWS Organizations (organization, OU, and account management)
  - AWS Control Tower landing zone operations
- Control Tower must be deployed in the configured home region (`aws_region`).

## Important AWS context

- Run this from the AWS Organizations management account.
- Account creation via `aws_organizations_account` is asynchronous and may take time.
- Control Tower API/resource support depends on account/region eligibility and service quotas.

## Inputs

Use `terraform.tfvars.example` as a template:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Key inputs:

- `client_name`, `project_name`, `environment`
- `aws_region`
- `enabled_regions`
- `organizational_units`
- `accounts`
- `control_tower`

## Organizational unit behavior and limitation

- OUs without `parent` are created under the Organization root.
- OUs with `parent` are created as a **single child level** under a top-level OU.
- Deeper nesting is intentionally rejected by validation to avoid fragile ordering logic.

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate -var-file=terraform.tfvars
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Outputs

Root outputs expose:

- Organization ID
- Root ID
- Management account ID
- Organizational unit details
- Account IDs and account details
- Control Tower landing zone details (ID/ARN/version and related fields exposed by provider)

## CI validation

GitHub Actions workflow `.github/workflows/terraform.yml` runs:

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate -var-file=terraform.tfvars.example`

No AWS credentials are required for these static checks.

## Limitations and assumptions

- This repository currently supports one-level child OUs (root + child).
- Existing pre-created Organizations/Control Tower resources are not automatically imported.
- Some landing zone runtime fields may be null when not returned by the provider/API.
- `enabled_regions` is retained as a root input for compatibility; landing zone governed regions are driven by `control_tower.governed_regions`.
