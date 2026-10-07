locals {
  root_ous = {
    for key, ou in var.organizational_units :
    key => ou
    if ou.parent == null
  }

  child_ous = {
    for key, ou in var.organizational_units :
    key => ou
    if ou.parent != null
  }
}

resource "aws_organizations_organizational_unit" "root" {
  for_each = local.root_ous

  name      = each.value.name
  parent_id = var.root_id
}

resource "aws_organizations_organizational_unit" "child" {
  for_each = local.child_ous

  name = each.value.name

  parent_id = aws_organizations_organizational_unit.root[
    each.value.parent
  ].id
}