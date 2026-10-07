variable "root_id" {
  description = "AWS Organizations root ID"
  type        = string

  validation {
    condition     = length(trimspace(var.root_id)) > 0
    error_message = "root_id must not be empty."
  }
}

variable "organizational_units" {
  description = "Organizational Unit configuration"

  type = map(object({
    name   = string
    parent = optional(string)
  }))

  validation {
    condition = alltrue([
      for key, ou in var.organizational_units :
      length(trimspace(ou.name)) > 0
    ])
    error_message = "Each organizational unit must include a non-empty name."
  }

  validation {
    condition = alltrue([
      for key, ou in var.organizational_units :
      ou.parent == null || contains(keys(var.organizational_units), ou.parent)
    ])
    error_message = "Each OU parent must reference another OU key in organizational_units."
  }

  validation {
    condition = alltrue([
      for key, ou in var.organizational_units :
      ou.parent == null || try(var.organizational_units[ou.parent].parent, null) == null
    ])
    error_message = "Only one child level is supported: parent references must target top-level OUs."
  }
}
