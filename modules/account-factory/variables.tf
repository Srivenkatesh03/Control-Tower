variable "product_id" {
  description = "Service Catalog product ID of 'AWS Control Tower Account Factory' (prod-xxxxxxxxxxxxx)"
  type        = string
}

variable "provisioning_artifact_id" {
  description = "Provisioning artifact (version) ID of the Account Factory product (pa-xxxxxxxxxxxxx)"
  type        = string
}

variable "portfolio_id" {
  description = "Account Factory portfolio ID. Set together with principal_arn to let Terraform's role launch the product."
  type        = string
  default     = null
}

variable "principal_arn" {
  description = "IAM role ARN that runs Terraform (not the sts assumed-role ARN)"
  type        = string
  default     = null
}

variable "accounts" {
  description = "Accounts to vend through Account Factory, keyed by account key"
  type = map(object({
    name                = string
    email               = string
    ou                  = string
    sso_user_email      = string
    sso_user_first_name = string
    sso_user_last_name  = string
  }))
  default = {}
}

variable "organizational_units" {
  description = "Organizational units keyed by OU key (must be registered with Control Tower)"
  type = map(object({
    id   = string
    name = string
  }))
}
