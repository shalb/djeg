terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "djeg/terraform.tfstate"
    region = "eu-central-1"
  }
}