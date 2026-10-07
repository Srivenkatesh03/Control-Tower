output "organization_id" {
  description = "AWS Organization ID"
  value       = module.organizations.organization_id
}

output "root_id" {
  description = "AWS Organizations root ID"
  value       = module.organizations.root_id
}

output "management_account_id" {
  description = "AWS Organizations management account ID"
  value       = module.organizations.management_account_id
}

output "organizational_units" {
  description = "Organizational units keyed by input key"
  value       = module.organizational_units.organizational_units
}

output "account_ids" {
  description = "Account IDs keyed by account key"
  value       = module.accounts.account_ids
}

output "accounts" {
  description = "Account details keyed by account key"
  value       = module.accounts.accounts
}

output "control_tower_landing_zone" {
  description = "Control Tower landing zone details"
  value       = module.control_tower.landing_zone
}

output "factory_account_ids" {
  description = "Account IDs vended through Account Factory"
  value       = local.factory_account_ids
}

output "ou_registration_baselines" {
  description = "Enabled Control Tower baselines per registered OU"
  value       = try(module.ou_registration[0].enabled_baselines, {})
}

output "identity_center_group_ids" {
  description = "Identity Center group IDs by group key"
  value       = try(module.identity_center[0].group_ids, {})
}

output "identity_center_permission_set_arns" {
  description = "Permission set ARNs by permission set key"
  value       = try(module.identity_center[0].permission_set_arns, {})
}