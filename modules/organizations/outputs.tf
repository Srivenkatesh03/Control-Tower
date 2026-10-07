output "organization_id" {
  description = "AWS Organization ID"
  value       = aws_organizations_organization.this.id
}

output "root_id" {
  description = "AWS Organizations root ID"
  value       = aws_organizations_organization.this.roots[0].id
}

output "management_account_id" {
  description = "AWS Management Account ID"
  value       = aws_organizations_organization.this.master_account_id
}