output "account_ids" {
  description = "AWS account IDs keyed by account key"
  value = {
    for key, account in aws_organizations_account.this :
    key => account.id
  }
}

output "accounts" {
  description = "AWS account details keyed by account key"
  value = {
    for key, account in aws_organizations_account.this :
    key => {
      id      = account.id
      arn     = account.arn
      name    = var.accounts[key].name
      email   = var.accounts[key].email
      ou      = var.accounts[key].ou
      ou_id   = var.organizational_units[var.accounts[key].ou].id
      ou_name = var.organizational_units[var.accounts[key].ou].name
    }
  }
}
