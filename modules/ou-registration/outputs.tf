output "enabled_baselines" {
  description = "ARNs of the enabled baselines, keyed by OU key"
  value = merge(
    { for key, baseline in aws_controltower_baseline.root : key => baseline.arn },
    { for key, baseline in aws_controltower_baseline.child : key => baseline.arn },
  )
}
