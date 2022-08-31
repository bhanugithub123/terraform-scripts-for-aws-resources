resource "aws_route53_zone" "bhanurajpoot16_aws" {
  name = "bhanurajpoot16.cf"

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.bhanurajpoot16_aws.zone_id
  name    = "www.bhanurajpoot16.cf"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip.public_ip]
}

output "name_server" {
  value = aws_route53_zone.bhanurajpoot16_aws.name_servers
}
