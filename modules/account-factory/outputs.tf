output "account_ids" {
  description = "Account IDs of the vended accounts, keyed by account key"
  value = {
    for key, product in aws_servicecatalog_provisioned_product.this :
    key => try(one([for o in product.outputs : o.value if o.key == "AccountId"]), null)
  }
}

output "provisioned_product_ids" {
  description = "Service Catalog provisioned product IDs, keyed by account key"
  value = {
    for key, product in aws_servicecatalog_provisioned_product.this :
    key => product.id
  }
}
