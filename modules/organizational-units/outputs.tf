output "organizational_units" {
  description = "Created organizational units"

  value = merge(
    {
      for key, ou in aws_organizations_organizational_unit.root :
      key => {
        id         = ou.id
        arn        = ou.arn
        name       = ou.name
        parent_key = null
        parent_id  = var.root_id
      }
    },
    {
      for key, ou in aws_organizations_organizational_unit.child :
      key => {
        id         = ou.id
        arn        = ou.arn
        name       = ou.name
        parent_key = var.organizational_units[key].parent
        parent_id  = aws_organizations_organizational_unit.root[var.organizational_units[key].parent].id
      }
    }
  )
}