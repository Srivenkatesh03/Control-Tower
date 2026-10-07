data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
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

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id, var.audit_account_id, var.log_archive_account_id]
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
