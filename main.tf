module "organizations" {
  source = "./modules/organizations"
}

module "organizational_units" {
  source = "./modules/organizational-units"

  root_id              = module.organizations.root_id
  organizational_units = var.organizational_units
}


module "accounts" {
  source = "./modules/accounts"

  accounts             = var.accounts
  organizational_units = module.organizational_units.organizational_units

  depends_on = [
    module.organizational_units
  ]
}

module "control_tower_iam" {
  source = "./modules/control-tower-iam"

}

module "control_tower" {
  source = "./modules/control-tower"

  landing_zone_version      = var.control_tower.landing_zone_version
  governed_regions          = var.control_tower.governed_regions
  log_archive_account_id    = module.accounts.account_ids[var.control_tower.log_archive_account_key]
  audit_account_id          = module.accounts.account_ids[var.control_tower.audit_account_key]
  security_ou_name          = var.control_tower.security_ou_name
  sandbox_ou_name           = var.control_tower.sandbox_ou_name
  log_retention_days        = var.control_tower.log_retention_days
  access_log_retention_days = var.control_tower.access_log_retention_days

  depends_on = [
    module.control_tower_iam
  ]
}

module "ou_registration" {
  count  = var.ou_registration.enabled ? 1 : 0
  source = "./modules/ou-registration"

  root_ous = {}

  child_ous = {
    dev = {
      arn  = module.organizational_units.organizational_units["dev"].arn
      name = module.organizational_units.organizational_units["dev"].name
    }
  }

  baseline_version                     = var.ou_registration.baseline_version
  identity_center_enabled_baseline_arn = var.ou_registration.identity_center_enabled_baseline_arn

  depends_on = [module.control_tower]
}

module "account_factory" {
  count  = length(var.factory_accounts) > 0 ? 1 : 0
  source = "./modules/account-factory"

  product_id               = var.account_factory.product_id
  provisioning_artifact_id = var.account_factory.provisioning_artifact_id
  portfolio_id             = var.account_factory.portfolio_id
  principal_arn            = var.account_factory.principal_arn

  accounts             = var.factory_accounts
  organizational_units = module.organizational_units.organizational_units

  depends_on = [module.control_tower, module.ou_registration]
}

locals {
  factory_account_ids = try(module.account_factory[0].account_ids, {})
}

module "identity_center" {
  count  = var.identity_center.enabled ? 1 : 0
  source = "./modules/identity-center"

  groups          = var.identity_center.groups
  users           = var.identity_center.users
  permission_sets = var.identity_center.permission_sets
  assignments     = var.identity_center.assignments

  account_ids = merge(
    module.accounts.account_ids,
    local.factory_account_ids,
    { management = module.organizations.management_account_id },
  )

  depends_on = [module.control_tower, module.account_factory]
}
