variable "accounts" {
  description = "Account definitions for the project"

  type = map(object({
    name  = string
    email = string
    ou    = string
  }))

  default = {}

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
}

variable "organizational_units" {
  description = "Organizational units keyed by OU key"

  type = map(object({
    id   = string
    name = string
  }))

  validation {
    condition = alltrue([
      for ou in values(var.organizational_units) : length(trimspace(ou.id)) > 0
    ])
    error_message = "Each organizational unit must include a non-empty id."
  }
}
