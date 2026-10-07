output "group_ids" {
  description = "Identity Center group IDs keyed by group key"
  value       = { for key, group in aws_identitystore_group.this : key => group.group_id }
}

output "permission_set_arns" {
  description = "Permission set ARNs keyed by permission set key"
  value       = { for key, ps in aws_ssoadmin_permission_set.this : key => ps.arn }
}
