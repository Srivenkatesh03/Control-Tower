terraform {
  backend "s3" {
    bucket       = "ct-s3-11461072026"
    key          = "control-tower-terraform/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
