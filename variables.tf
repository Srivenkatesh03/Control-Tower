variable "client_name" {
  description = "Name of the client"
  type        = string

  validation {
    condition     = length(trimspace(var.client_name)) > 0
    error_message = "client_name must not be empty."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "aws_region" {
  description = "AWS Control Tower home region"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must look like a valid AWS region (for example, us-east-1)."
  }
}

variable "enabled_regions" {
  description = "AWS regions governed by the landing zone"
  type        = list(string)

  validation {
    condition = length(var.enabled_regions) > 0 && alltrue([
      for region in var.enabled_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", region))
    ])
    error_message = "enabled_regions must include at least one valid AWS region name."
  }
}

variable "environment" {
  description = "Primary project environment"
  type        = string

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

variable "mandatory_tags" {
  description = "Mandatory tags applied to AWS resources"
  type        = map(string)

  default = {}
}

variable "organizational_units" {
  description = "Organizational Units required by the project"

  type = map(object({
    name   = string
    parent = optional(string)
  }))

  default = {}

  validation {
    condition = alltrue([
      for key, ou in var.organizational_units :
      ou.parent == null || contains(keys(var.organizational_units), ou.parent)
    ])
    error_message = "Each OU parent must reference another OU key from organizational_units."
  }

  validation {
    condition = alltrue([
      for key, ou in var.organizational_units :
      ou.parent == null || try(var.organizational_units[ou.parent].parent, null) == null
    ])
    error_message = "Nested OU parents deeper than one child level are not supported. Child OUs must reference a top-level OU."
  }
}

variable "accounts" {
  description = "AWS accounts to create"

  type = map(object({
    name  = string
    email = string
    ou    = string
  }))

  validation {
    condition = alltrue([
      for account in values(var.accounts) :
      length(trimspace(account.name)) > 0 &&
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", account.email)) &&
      length(trimspace(account.ou)) > 0
    ])
    error_message = "Each account must include non-empty name/ou values and a valid email format."
  }

  validation {
    condition     = length(distinct([for account in values(var.accounts) : lower(account.email)])) == length(var.accounts)
    error_message = "Account email values must be unique."
  }

  validation {
    condition = alltrue([
      for account in values(var.accounts) : contains(keys(var.organizational_units), account.ou)
    ])
    error_message = "Each account.ou must reference a key from organizational_units."
  }
}

variable "control_tower" {
  description = "Control Tower configuration"

  type = object({
    landing_zone_version      = string
    governed_regions          = list(string)
    log_archive_account_key   = optional(string, "log_archive")
    audit_account_key         = optional(string, "audit")
    security_ou_name          = optional(string, "Security")
    sandbox_ou_name           = optional(string, "Sandbox")
    log_retention_days        = optional(number, 365)
    access_log_retention_days = optional(number, 365)
  })

  validation {
    condition     = length(trimspace(var.control_tower.landing_zone_version)) > 0
    error_message = "control_tower.landing_zone_version must not be empty."
  }

  validation {
    condition = length(var.control_tower.governed_regions) > 0 && alltrue([
      for region in var.control_tower.governed_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", region))
    ])
    error_message = "control_tower.governed_regions must include at least one valid AWS region name."
  }

  validation {
    condition = (
      contains(keys(var.accounts), var.control_tower.log_archive_account_key) &&
      contains(keys(var.accounts), var.control_tower.audit_account_key) &&
      var.control_tower.log_archive_account_key != var.control_tower.audit_account_key
    )
    error_message = "log_archive_account_key and audit_account_key must be two different keys of var.accounts."
  }

  validation {
    condition     = !contains([for ou in values(var.organizational_units) : lower(ou.name)], lower(var.control_tower.security_ou_name)) && !contains([for ou in values(var.organizational_units) : lower(ou.name)], lower(var.control_tower.sandbox_ou_name))
    error_message = "Do not define OUs named like the Control Tower Security/Sandbox OUs in organizational_units; the landing zone creates them."
  }
}

variable "ou_registration" {
  description = "Phase 2: register custom OUs with Control Tower."
  type = object({
    enabled                              = optional(bool, false)
    baseline_version                     = optional(string, "4.0")
    identity_center_enabled_baseline_arn = optional(string)
  })
  default = {}

  validation {
    condition     = !var.ou_registration.enabled || var.ou_registration.identity_center_enabled_baseline_arn != null
    error_message = "identity_center_enabled_baseline_arn is required when registration is enabled."
  }
}

variable "account_factory" {
  description = "Account Factory (Service Catalog) IDs. Required when factory_accounts is not empty."
  type = object({
    product_id               = string
    provisioning_artifact_id = string
    portfolio_id             = optional(string)
    principal_arn            = optional(string)
  })
  default = null
}

variable "factory_accounts" {
  description = "Workload accounts vended through Account Factory."
  type = map(object({
    name                = string
    email               = string
    ou                  = string
    sso_user_email      = string
    sso_user_first_name = string
    sso_user_last_name  = string
  }))
  default = {}

  validation {
    condition     = length(var.factory_accounts) == 0 || var.account_factory != null
    error_message = "Set account_factory when factory_accounts is not empty."
  }

  validation {
    condition = alltrue([
      for account in values(var.factory_accounts) : contains(keys(var.organizational_units), account.ou)
    ])
    error_message = "Each factory_accounts[*].ou must be a key of organizational_units."
  }

  validation {
    condition = length(distinct(concat(
      [for account in values(var.accounts) : lower(account.email)],
      [for account in values(var.factory_accounts) : lower(account.email)],
    ))) == length(var.accounts) + length(var.factory_accounts)
    error_message = "Emails must be unique across accounts and factory_accounts."
  }
}

variable "identity_center" {
  description = "IAM Identity Center configuration, applied after the landing zone exists."
  type = object({
    enabled = optional(bool, false)
    groups = optional(map(object({
      name        = string
      description = optional(string, "")
    })), {})
    users = optional(map(object({
      user_name    = string
      display_name = string
      given_name   = string
      family_name  = string
      email        = string
      groups       = optional(list(string), [])
    })), {})
    permission_sets = optional(map(object({
      name             = string
      description      = optional(string, "")
      session_duration = optional(string, "PT8H")
      managed_policies = optional(list(string), [])
    })), {})
    assignments = optional(map(object({
      group          = string
      permission_set = string
      account        = string
    })), {})
  })
  default = {}

  validation {
    condition = alltrue([
      for a in values(var.identity_center.assignments) :
      contains(keys(var.identity_center.groups), a.group) &&
      contains(keys(var.identity_center.permission_sets), a.permission_set)
    ])
    error_message = "Each assignment must use a group key and permission_set key defined in identity_center."
  }

  validation {
    condition = alltrue([
      for u in values(var.identity_center.users) :
      alltrue([for g in u.groups : contains(keys(var.identity_center.groups), g)])
    ])
    error_message = "Each user's groups must be keys of identity_center.groups."
  }
}