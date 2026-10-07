output "landing_zone" {
  description = "Control Tower landing zone details"
  value = {
    id                       = aws_controltower_landing_zone.this.id
    arn                      = aws_controltower_landing_zone.this.arn
    version                  = aws_controltower_landing_zone.this.version
    governed_regions         = var.governed_regions
    manifest_json            = aws_controltower_landing_zone.this.manifest_json
    latest_available_version = try(aws_controltower_landing_zone.this.latest_available_version, null)
    drift_status             = try(aws_controltower_landing_zone.this.drift_status, null)
  }
}

output "kms_key_arn" {
  description = "KMS key used for Control Tower logging"
  value       = aws_kms_key.control_tower.arn
}
