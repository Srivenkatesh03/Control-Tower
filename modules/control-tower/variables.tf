variable "landing_zone_version" {
  description = "AWS Control Tower landing zone version"
  type        = string

  validation {
    condition     = length(trimspace(var.landing_zone_version)) > 0
    error_message = "landing_zone_version must not be empty."
  }
}

variable "governed_regions" {
  description = "AWS regions governed by Control Tower (must include the home region)"
  type        = list(string)

  validation {
    condition = length(var.governed_regions) > 0 && alltrue([
      for region in var.governed_regions : can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", region))
    ])
    error_message = "governed_regions must include at least one valid AWS region name."
  }
}

variable "log_archive_account_id" {
  description = "Existing account ID used as the Log Archive account"
  type        = string
}

variable "audit_account_id" {
  description = "Existing account ID used as the Audit account"
  type        = string
}

variable "security_ou_name" {
  description = "Name of the Security OU that Control Tower creates"
  type        = string
  default     = "Security"
}

variable "sandbox_ou_name" {
  description = "Name of the Sandbox OU that Control Tower creates"
  type        = string
  default     = "Sandbox"
}

variable "log_retention_days" {
  description = "Retention (days) for the centralized logging bucket"
  type        = number
  default     = 365
}

variable "access_log_retention_days" {
  description = "Retention (days) for the access logging bucket"
  type        = number
  default     = 365
}
