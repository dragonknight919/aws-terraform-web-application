# The resources below contain some count, for_each etc. statements
# to handle a custom domain name for AWS CloudFront
# if one was provided as input variable to Terraform.
# Terraform support for count, for_each etc. statements
# in module blocks would greatly beautify this code section.

resource "aws_acm_certificate" "cert" {
  count = var.alternate_domain_name == "" ? 0 : 1

  # CloudFront accepts only ACM certificates from US-EAST-1
  provider = aws.useast1

  domain_name               = var.alternate_domain_name
  subject_alternative_names = [local.alternate_domain_name_www]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "apex_cert_validation" {
  count = var.alternate_domain_name == "" ? 0 : 1

  name    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
  type    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
}

resource "aws_route53_record" "www_cert_validation" {
  count = var.alternate_domain_name == "" ? 0 : 1

  name    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[1].resource_record_name
  records = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[1].resource_record_value]
  ttl     = 60
  type    = tolist(aws_acm_certificate.cert[0].domain_validation_options)[1].resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  count = var.alternate_domain_name == "" ? 0 : 1

  # CloudFront accepts only ACM certificates from US-EAST-1
  provider = aws.useast1

  certificate_arn = aws_acm_certificate.cert[0].arn

  validation_record_fqdns = [
    aws_route53_record.apex_cert_validation[0].fqdn,
    aws_route53_record.www_cert_validation[0].fqdn
  ]
}

resource "aws_cloudfront_distribution" "minimal_distribution" {
  origin {
    domain_name = aws_s3_bucket.minimal_frontend_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.minimal_frontend_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.minimal_cloudfront_identity.cloudfront_access_identity_path
    }
  }

  aliases             = var.alternate_domain_name == "" ? [] : [var.alternate_domain_name, local.alternate_domain_name_www]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.minimal_frontend_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # conditional nested blocks are not supported by Terraform, therefore this hack
  dynamic "viewer_certificate" {
    for_each = var.alternate_domain_name == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.alternate_domain_name == "" ? [] : [1]
    content {
      acm_certificate_arn = aws_acm_certificate_validation.cert[0].certificate_arn
      ssl_support_method  = "sni-only"
    }
  }
}

module "alias_a_records" {
  for_each = toset(var.alternate_domain_name == "" ? [] : [
    var.alternate_domain_name,
    local.alternate_domain_name_www
    ]
  )

  source = "./modules/route53_alias_a_records"

  dns_record_name = each.key

  hosted_zone_id       = data.aws_route53_zone.selected[0].zone_id
  alias_domain_name    = aws_cloudfront_distribution.minimal_distribution.domain_name
  alias_hosted_zone_id = aws_cloudfront_distribution.minimal_distribution.hosted_zone_id
}
