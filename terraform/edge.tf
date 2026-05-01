data "aws_caller_identity" "current" {}

locals {
  frontend_sites = merge({
    customer = {
      origin_domain = var.shared_ingress_domain_name != "" ? var.shared_ingress_domain_name : var.customer_ingress_domain_name
    }
  }, var.enable_vpn ? {} : {
    admin = {
      origin_domain = var.shared_ingress_domain_name != "" ? var.shared_ingress_domain_name : var.admin_ingress_domain_name
    }
  })
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
  aliases             = []
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
    target_origin_id         = "shopcloud-${each.key}-origin"
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
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
