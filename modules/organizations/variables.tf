variable "enabled_policy_types" {
  description = "AWS Organizations policy types to enable"
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]

  validation {
    condition     = length(var.enabled_policy_types) > 0
    error_message = "enabled_policy_types must include at least one policy type."
  }
}

variable "aws_service_access_principals" {
  description = "AWS services granted trusted access to the organization"
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "controltower.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "ram.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "sso.amazonaws.com",
  ]
}
