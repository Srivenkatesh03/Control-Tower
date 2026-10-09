terraform {
  backend "s3" {
    bucket       = "Your-unique-bucket-name"
    key          = "control-tower-terraform/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
