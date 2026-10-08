locals {
  landing_zone_manifest = {
    governedRegions = var.governed_regions

    backup = {
      enabled = false
    }

    centralizedLogging = {
      accountId = var.log_archive_account_id
      enabled   = true

      configurations = {
        loggingBucket = {
          retentionDays = var.log_retention_days
        }

        accessLoggingBucket = {
          retentionDays = var.access_log_retention_days
        }

        kmsKeyArn = aws_kms_key.control_tower.arn
      }
    }

    # AWS Config integration
    config = {
      accountId = var.audit_account_id
      enabled   = true

      configurations = {
        loggingBucket = {
          retentionDays = var.log_retention_days
        }

        accessLoggingBucket = {
          retentionDays = var.access_log_retention_days
        }

        kmsKeyArn = aws_kms_key.control_tower.arn
      }
    }

    securityRoles = {
      accountId = var.audit_account_id
      enabled   = true
    }

    accessManagement = {
      enabled = true
    }
  }
}

resource "aws_controltower_landing_zone" "this" {
  manifest_json = jsonencode(local.landing_zone_manifest)
  version       = var.landing_zone_version

  remediation_types = [
    "INHERITANCE_DRIFT"
  ]

  lifecycle {
    prevent_destroy = true
  }
}
