output "acm_dns_validation_records" {
  value = [
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
      # For DNS UIs that only ask for "Host" (zone auto-appended): use this in Host field
      host   = trimsuffix(dvo.resource_record_name, ".${var.domain_name}.")
    }
  ]
  description = "Add these DNS records to your DNS provider for ACM validation"
}


output "site_cert" {
  value = aws_acm_certificate.site_cert.arn
}


