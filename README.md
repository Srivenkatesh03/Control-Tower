# AWS Control Tower Terraform

Terraform configuration for provisioning and managing an AWS Organization, organizational units (OUs), AWS accounts, AWS Control Tower, OU registration, Account Factory accounts, and IAM Identity Center resources.

> **Status:** This project is intended to be run from the AWS Organizations management account. Review and customize all environment-specific values before applying.

## Architecture

The root Terraform configuration calls the following modules:

- `modules/organizations` — Creates the AWS Organization and enables trusted service access.
- `modules/organizational-units` — Creates root and child organizational units.
- `modules/accounts` — Creates AWS member accounts and places them in OUs.
- `modules/control-tower-iam` — Creates IAM prerequisites for AWS Control Tower.
- `modules/control-tower` — Configures the Control Tower landing zone and KMS resources.
- `modules/ou-registration` — Registers OUs with AWS Control Tower baselines.
- `modules/account-factory` — Provisions accounts through AWS Service Catalog Account Factory.
- `modules/identity-center` — Configures IAM Identity Center groups, users, permission sets, and assignments.

## Prerequisites

- Terraform `>= 1.9.0`
- AWS provider `~> 6.0`
- An AWS account with access to the AWS Organizations management account
- AWS credentials with permissions for:
  - AWS Organizations
  - AWS Control Tower
  - IAM and KMS
  - AWS Service Catalog, if Account Factory is enabled
  - IAM Identity Center, if Identity Center is enabled
- AWS Control Tower available in the configured home region

## Important AWS considerations

- Run this configuration from the AWS Organizations management account.
- AWS account creation is asynchronous and may take several minutes.
- AWS Control Tower availability and API behavior depend on the selected region, account status, quotas, and service eligibility.
- Existing Organizations or Control Tower resources are not automatically imported. Import existing resources before managing them with Terraform.
- Test changes in a non-production environment before applying them to a production organization.

## Configuration

Create a local variables file from the example file when available:

```bash
cp terraform.tfvars.example terraform.tfvars
```

The main configuration areas are:

- `client_name`
- `project_name`
- `environment`
- `aws_region`
- `enabled_regions`
- `mandatory_tags`
- `organizational_units`
- `accounts`
- `control_tower`
- `ou_registration`
- `account_factory`
- `factory_accounts`
- `identity_center`

Do not commit real account email addresses, sensitive identifiers, or private environment-specific values. Add local `.tfvars` files to `.gitignore` where appropriate.

## Organizational units

OUs without a `parent` are created under the AWS Organizations root. OUs with a `parent` are created under another OU.

The current implementation supports a root OU and one child level. For example:

```hcl
organizational_units = {
  workloads = {
    name = "Workloads"
  }

  development = {
    name   = "Development"
    parent = "workloads"
  }
}
```

The current validation intentionally rejects deeper nesting. Supporting additional levels requires updating the organizational unit module resources, dependency ordering, outputs, and validation together.

## OU registration

OU registration is optional and controlled by `ou_registration.enabled`.

When enabled, provide:

- A valid Control Tower baseline version
- The Identity Center enabled baseline ARN when required
- The OUs that should be registered with Control Tower

Control Tower baseline identifiers and versions are region-specific. Confirm the correct values with the AWS Control Tower APIs before applying.

## IAM Identity Center

IAM Identity Center is disabled by default. Enable it only after confirming that an IAM Identity Center instance exists in the target region.

The configuration supports:

- Groups
- Users
- Group memberships
- Permission sets
- AWS managed policy attachments
- Account assignments

Use least-privilege permission sets wherever possible. Avoid granting `AdministratorAccess` broadly unless it is explicitly required.

## Account Factory

Account Factory is optional. To use it:

1. Provide the Service Catalog product ID.
2. Provide the provisioning artifact ID.
3. Provide portfolio and principal values when required.
4. Define `factory_accounts`.
5. Ensure all referenced OU keys exist.
6. Ensure account email addresses are unique.

Account Factory provisioning can take time and may require additional AWS Control Tower and Service Catalog setup.

## Usage

Format the Terraform files:

```bash
terraform fmt -recursive
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate -var-file=terraform.tfvars
```

Review the execution plan:

```bash
terraform plan -var-file=terraform.tfvars
```

Apply the configuration only after reviewing the plan:

```bash
terraform apply -var-file=terraform.tfvars
```

For a first deployment, the resources can also be applied in stages, although targeted applies should be used carefully:

```bash
terraform apply -target=module.organizations -var-file=terraform.tfvars
terraform apply -target=module.organizational_units -var-file=terraform.tfvars
terraform apply -target=module.accounts -var-file=terraform.tfvars
terraform apply -target=module.control_tower_iam -var-file=terraform.tfvars
terraform apply -target=module.control_tower -var-file=terraform.tfvars
```

## State and backend

The `backend` directory contains Terraform configuration for an S3 state bucket. Review and customize the bucket name, region, encryption, access controls, and locking strategy before using it.

Terraform state can contain sensitive infrastructure information. Protect the state bucket and restrict access to authorized operators only.

## Outputs

The root module exposes outputs for:

- AWS Organization ID
- Organizations root ID
- Management account ID
- Organizational unit details
- Account IDs and account details
- Control Tower landing zone details
- Account Factory account IDs
- Control Tower OU registration baseline ARNs

## CI validation

The GitHub Actions workflow runs static Terraform checks such as:

- Recursive Terraform formatting validation
- Terraform initialization without a backend
- Terraform configuration validation using the example variables file

These checks do not replace an AWS-backed plan or deployment test.

## Troubleshooting

### Invalid OU parent

Verify that every `parent` value references an existing key in `organizational_units`.

### Nested OU validation error

The current module supports only one child level. Deeper OU hierarchies require an implementation change in `modules/organizational-units` and its validation rules.

### Missing account or OU key

Check that account `ou` values, Control Tower account keys, factory account OU values, and Identity Center assignment account values match keys defined in the corresponding maps.

### Control Tower baseline errors

Confirm the baseline version, baseline ARN, AWS region, and Control Tower enrollment status. These values must match the target AWS environment.

## Limitations and assumptions

- The current organizational unit module supports root OUs and one child level.
- Existing AWS Organizations and Control Tower resources are not automatically imported.
- AWS account creation and Control Tower operations are asynchronous.
- Some runtime fields returned by AWS may be null or unavailable during planning.
- Account emails must be unique.
- `enabled_regions` is retained as a root input for compatibility; Control Tower governed regions are configured through `control_tower.governed_regions`.

## Security recommendations

- Never commit AWS access keys or secret keys.
- Avoid committing real credentials, personal email addresses, or sensitive account identifiers.
- Use IAM roles and short-lived credentials where possible.
- Use least-privilege IAM policies.
- Enable S3 versioning and encryption for Terraform state.
- Restrict access to Terraform state and CI/CD secrets.
- Review every production plan before applying it.

## License

No license has been specified for this repository. Add a license file if you intend to distribute or reuse this project publicly.
