locals {
  create_roles = var.enabled
}

data "aws_partition" "current" {}

resource "aws_iam_role" "control_tower_admin" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerAdmin"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "controltower.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "control_tower_admin" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerAdminPolicy"
  role = aws_iam_role.control_tower_admin[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:DescribeAvailabilityZones"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "control_tower_admin" {
  count = local.create_roles ? 1 : 0

  role       = aws_iam_role.control_tower_admin[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

resource "aws_iam_role" "cloudtrail" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerCloudTrailRole"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerCloudTrailRolePolicy"
  role = aws_iam_role.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "arn:${data.aws_partition.current.partition}:logs:*:*:log-group:aws-controltower/CloudTrailLogs:*"
    }]
  })
}

resource "aws_iam_role" "stackset" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerStackSetRole"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudformation.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "stackset" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.stackset[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sts:AssumeRole"]
      Resource = ["arn:${data.aws_partition.current.partition}:iam::*:role/AWSControlTowerExecution"]
    }]
  })
}

resource "aws_iam_role" "config_aggregator" {
  count = local.create_roles ? 1 : 0

  name = "AWSControlTowerConfigAggregatorRoleForOrganizations"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  count = local.create_roles ? 1 : 0

  role       = aws_iam_role.config_aggregator[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
