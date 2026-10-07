resource "aws_servicecatalog_principal_portfolio_association" "terraform" {
  count = var.portfolio_id != null && var.principal_arn != null ? 1 : 0

  portfolio_id  = var.portfolio_id
  principal_arn = var.principal_arn
}

resource "aws_servicecatalog_provisioned_product" "this" {
  for_each = var.accounts

  name                     = each.value.name
  product_id               = var.product_id
  provisioning_artifact_id = var.provisioning_artifact_id

  provisioning_parameters {
    key   = "AccountName"
    value = each.value.name
  }

  provisioning_parameters {
    key   = "AccountEmail"
    value = each.value.email
  }

  provisioning_parameters {
    key   = "SSOUserEmail"
    value = each.value.sso_user_email
  }

  provisioning_parameters {
    key   = "SSOUserFirstName"
    value = each.value.sso_user_first_name
  }

  provisioning_parameters {
    key   = "SSOUserLastName"
    value = each.value.sso_user_last_name
  }

  provisioning_parameters {
    key   = "ManagedOrganizationalUnit"
    value = "${var.organizational_units[each.value.ou].name} (${var.organizational_units[each.value.ou].id})"
  }

  depends_on = [aws_servicecatalog_principal_portfolio_association.terraform]

  lifecycle {
    precondition {
      condition     = contains(keys(var.organizational_units), each.value.ou)
      error_message = "Factory account '${each.key}' references unknown OU key '${each.value.ou}'."
    }
  }
}
