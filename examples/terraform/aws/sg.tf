data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "sg_ci" {
  name        = "sg_${var.name}"
  description = "Allows all traffic"
  vpc_id      = "${data.aws_vpc.default.id}"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["91.224.10.99/32", "91.224.11.15/32"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["91.224.10.99/32", "91.224.11.15/32", "193.111.48.138/32", "91.195.75.234/32", "0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["91.224.10.99/32", "91.224.11.15/32", "193.111.48.138/32", "91.195.75.234/32", "0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["91.224.10.99/32", "91.224.11.15/32", "193.111.48.138/32", "91.195.75.234/32"]
  }

  # JNLP
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["91.224.10.99/32", "91.224.11.15/32", "193.111.48.138/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}