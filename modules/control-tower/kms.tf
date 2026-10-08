data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_organizations_organization" "this" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  org_account_ids = [
    for a in data.aws_organizations_organization.this.accounts : a.id
    if a.status == "ACTIVE"
  ]
}

data "aws_iam_policy_document" "ct_kms" {
  statement {
    sid       = "KeyAdministration"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowConfigToUseKey"
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = var.restrict_config_key_to_org_accounts ? [1] : []
      content {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = local.org_account_ids
      }
    }
  }

  statement {
    sid       = "AllowCloudTrailToUseKey"
    actions   = ["kms:GenerateDataKey*", "kms:DescribeKey", "kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${data.aws_region.current.region}:${local.account_id}:trail/aws-controltower-BaselineCloudTrail"]
    }
  }
}

resource "aws_kms_key" "control_tower" {
  description             = "Control Tower landing zone logging encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.ct_kms.json

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "control_tower" {
  name          = "alias/control-tower"
  target_key_id = aws_kms_key.control_tower.key_id
}
