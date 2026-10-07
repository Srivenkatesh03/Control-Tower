variable "root_ous" {
  description = "Top-level OUs to register with Control Tower, keyed by OU key"
  type = map(object({
    arn  = string
    name = string
  }))
}

variable "child_ous" {
  description = "Child OUs to register (registered after their parents)"
  type = map(object({
    arn  = string
    name = string
  }))
}

variable "baseline_version" {
  description = "Version of the AWSControlTowerBaseline to enable. Check with: aws controltower list-baselines"
  type        = string
}

variable "identity_center_enabled_baseline_arn" {
  description = "ARN of the enabled Identity Center baseline created by Control Tower. Find it with: aws controltower list-enabled-baselines"
  type        = string
  default     = null
}
