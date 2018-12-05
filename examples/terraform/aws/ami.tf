data "aws_ami" "djeg" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-djeg-18.04*"]
  }
}