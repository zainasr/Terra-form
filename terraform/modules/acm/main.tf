resource "aws_acm_certificate" "site_cert" {
  domain_name       = "imdbreview.me"
  # Add this to cover both!
  subject_alternative_names = ["www.imdbreview.me"] 
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_route53_zone" "main" {
  name = "imdbreview.me"
}



# Create DNS Records for Validation (Automated)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "site_cert_validate" {
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}



resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "imdbreview.me"
  type    = "A"

  alias {
    name                   = "${var.alb_dns_name}"
    zone_id                = "${var.zone_id}"
    evaluate_target_health = true
  }
}

# Repeat for WWW
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.imdbreview.me"
  type    = "A"

  alias {
    name                   =  "${var.alb_dns_name}"
    zone_id                =   "${var.zone_id}"
    evaluate_target_health = true
  }
}