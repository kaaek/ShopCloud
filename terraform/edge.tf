data "aws_caller_identity" "current" {}

locals {
  root_domain_name = trimsuffix(var.root_domain_name, ".")

  frontend_sites = {
    customer = {
      domain_name = local.root_domain_name
      origin_domain = var.shared_ingress_domain_name != "" ? var.shared_ingress_domain_name : var.customer_ingress_domain_name
    }
    admin = {
      domain_name = "${var.admin_record_name}.${local.root_domain_name}"
      origin_domain = var.shared_ingress_domain_name != "" ? var.shared_ingress_domain_name : var.admin_ingress_domain_name
    }
  }

  customer_alias_name = "${var.customer_record_name}.${local.root_domain_name}"
}

resource "aws_route53_zone" "shopcloud" {
  name = local.root_domain_name

  tags = {
    Name        = "ShopCloud-Hosted-Zone"
    Environment = var.environment
  }
}

resource "aws_wafv2_web_acl" "cloudfront" {
  provider    = aws.us_east_1
  name        = var.waf_name
  description = "CloudFront protection for ShopCloud"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "shopcloud-cloudfront-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedLinuxRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "forward_all_headers" {
  name    = "shopcloud-forward-all-headers"
  comment = "Forward the viewer request headers needed by the ingress controller"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "allViewer"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_origin_request_policy" "forward_host_and_query" {
  name    = "shopcloud-forward-host-and-query"
  comment = "Forward the host header and query string to the ingress controller"

  cookies_config {
    cookie_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"

    headers {
      items = ["Host"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "frontend" {
  for_each = local.frontend_sites

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "ShopCloud ${title(each.key)} frontend"
  aliases             = [each.value.domain_name]
  price_class         = var.cloudfront_price_class
  web_acl_id          = aws_wafv2_web_acl.cloudfront.arn

  origin {
    domain_name = each.value.origin_domain
    origin_id                = "shopcloud-${each.key}-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "shopcloud-customer-origin"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    compress                 = true
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_all_headers.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "customer_root_a" {
  zone_id = aws_route53_zone.shopcloud.zone_id
  name    = local.root_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend["customer"].domain_name
    zone_id                = aws_cloudfront_distribution.frontend["customer"].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "customer_root_aaaa" {
  zone_id = aws_route53_zone.shopcloud.zone_id
  name    = local.root_domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.frontend["customer"].domain_name
    zone_id                = aws_cloudfront_distribution.frontend["customer"].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "customer_alias_a" {
  zone_id = aws_route53_zone.shopcloud.zone_id
  name    = local.customer_alias_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend["customer"].domain_name
    zone_id                = aws_cloudfront_distribution.frontend["customer"].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "customer_alias_aaaa" {
  zone_id = aws_route53_zone.shopcloud.zone_id
  name    = local.customer_alias_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.frontend["customer"].domain_name
    zone_id                = aws_cloudfront_distribution.frontend["customer"].hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name = var.root_domain_name

  subject_alternative_names = [
    "${var.customer_record_name}.${var.root_domain_name}"
  ]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "shopcloud-cloudfront-cert"
  }
}

resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.shopcloud.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_validation : record.fqdn]
}