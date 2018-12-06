resource "aws_route53_record" "djeg" {
  zone_id = "${var.dns_zone_id}"
  name    = "djeg.${var.dns_zonename}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.djeg_elastic_ip.public_ip}"]
}

resource "aws_route53_record" "djeg-star" {
  zone_id = "${var.dns_zone_id}"
  name    = "*.djeg.${var.dns_zonename}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.djeg_elastic_ip.public_ip}"]
}