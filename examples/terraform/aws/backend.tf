terraform {
  backend "s3" {
    bucket = "terraform-djeg"
    key    = "terraform.tfstate"
    region = "eu-central-1"
    profile = "shalb"
  }
}