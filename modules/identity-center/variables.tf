variable "groups" {
  description = "Identity Center groups, keyed by group key"
  type = map(object({
    name        = string
    description = optional(string, "")
  }))
  default = {}
}

variable "users" {
  description = "Identity Center users, keyed by user key. 'groups' lists group keys."
  type = map(object({
    user_name    = string
    display_name = string
    given_name   = string
    family_name  = string
    email        = string
    groups       = optional(list(string), [])
  }))
  default = {}
}

variable "permission_sets" {
  description = "Permission sets, keyed by permission set key. managed_policies take a policy name (AdministratorAccess, job-function/ViewOnlyAccess) or a full ARN."
  type = map(object({
    name             = string
    description      = optional(string, "")
    session_duration = optional(string, "PT8H")
    managed_policies = optional(list(string), [])
  }))
  default = {}
}

variable "assignments" {
  description = "Group-to-account assignments. 'account' is an account key, or 'management'."
  type = map(object({
    group          = string
    permission_set = string
    account        = string
  }))
  default = {}
}

variable "account_ids" {
  description = "Account IDs keyed by account key (including 'management')"
  type        = map(string)
}
