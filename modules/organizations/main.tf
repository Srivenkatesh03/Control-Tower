resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  enabled_policy_types          = var.enabled_policy_types
  aws_service_access_principals = var.aws_service_access_principals

  lifecycle {
    ignore_changes = [aws_service_access_principals]
  }
}
