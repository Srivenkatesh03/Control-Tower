client_name  = "acme"
project_name = "landing-zone"
environment  = "dev"

aws_region      = "ap-south-1"
enabled_regions = ["ap-south-1"]

mandatory_tags = {
  ManagedBy = "terraform"
  Project   = "landing-zone"
}

organizational_units = {
  workloads = { name = "Workloads" }
  dev       = { name = "dev" }
}

accounts = {
  log_archive = { name = "log-archive", email = "srive004+log@gmail.com", ou = "workloads" }
  audit       = { name = "audit", email = "srive004+audit@gmail.com", ou = "workloads" }
  dev         = { name = "dev", email = "srive004+dev@gmail.com", ou = "dev" }
}

control_tower = {
  landing_zone_version = "4.0"
  governed_regions     = ["ap-south-1"]
}

ou_registration = {
  enabled                              = true
  baseline_version                     = "5.0"
  identity_center_enabled_baseline_arn = "arn:aws:controltower:ap-south-1:405617742426:enabledbaseline/XAIJPJOAG7I6ZVBK8"
}

# account_factory = {
#   product_id               = "prod-xxxxxxxxxxxxx"
#   provisioning_artifact_id = "pa-xxxxxxxxxxxxx"
#   portfolio_id             = "port-xxxxxxxxxxxxx"
#   principal_arn            = "arn:aws:iam::111111111111:role/terraform-admin"
# }

# factory_accounts = {
#   dev = {
#     name                = "devaccount"
#     email               = "aws-prod@example.com"
#     ou                  = "dev"
#     sso_user_email      = "owner@example.com"
#     sso_user_first_name = "Account"
#     sso_user_last_name  = "Owner"
#   }
# }

identity_center = {
  enabled = true
  groups = {
    platform_admins = { name = "platform-admins", description = "Full access" }
  }
  users = {
    srivenkatesh = {
      user_name    = "srive004+iam@gmail.com"
      display_name = "sriV"
      given_name   = "Sri"
      family_name  = "test"
      email        = "srive004+iam@gmail.com"
      groups       = ["platform_admins"]
    }
  }
  permission_sets = {
    admin = { name = "AdministratorAccess", description = "Administrator access for the dev account", managed_policies = ["AdministratorAccess"] }
  }
  assignments = {
    # admins_mgmt = { group = "platform_admins", permission_set = "admin", account = "management" }
    admins_dev = { group = "platform_admins", permission_set = "admin", account = "dev" }
  }
}

