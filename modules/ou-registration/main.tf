data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  baseline_arn = "arn:${data.aws_partition.current.partition}:controltower:${data.aws_region.current.region}::baseline/17BSJV3IGJ2QSGA2"
}

resource "aws_controltower_baseline" "root" {
  for_each = var.root_ous

  baseline_identifier = local.baseline_arn
  baseline_version    = var.baseline_version
  target_identifier   = each.value.arn

  dynamic "parameters" {
    for_each = var.identity_center_enabled_baseline_arn == null ? [] : [var.identity_center_enabled_baseline_arn]

    content {
      key   = "IdentityCenterEnabledBaselineArn"
      value = parameters.value
    }
  }
}

resource "aws_controltower_baseline" "child" {
  for_each = var.child_ous

  baseline_identifier = local.baseline_arn
  baseline_version    = var.baseline_version
  target_identifier   = each.value.arn

  dynamic "parameters" {
    for_each = var.identity_center_enabled_baseline_arn == null ? [] : [var.identity_center_enabled_baseline_arn]

    content {
      key   = "IdentityCenterEnabledBaselineArn"
      value = parameters.value
    }
  }

  depends_on = [aws_controltower_baseline.root]
}
