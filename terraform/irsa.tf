locals {
  oidc_issuer_without_https = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  service_accounts = {
    auth = {
      namespace = "shopcloud"
      name      = "auth-service-sa"
    }
    admin = {
      namespace = "shopcloud"
      name      = "admin-service-sa"
    }
    catalog = {
      namespace = "shopcloud"
      name      = "catalog-service-sa"
    }
    cart = {
      namespace = "shopcloud"
      name      = "cart-service-sa"
    }
    checkout = {
      namespace = "shopcloud"
      name      = "checkout-service-sa"
    }
  }
}

data "aws_iam_policy_document" "pod_assume_role" {
  for_each = local.service_accounts

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_without_https}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_without_https}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.name}"]
    }
  }
}

resource "aws_iam_role" "pod_irsa" {
  for_each = local.service_accounts

  name               = "shopcloud-${each.key}-irsa-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume_role[each.key].json
}

resource "aws_iam_policy" "common_runtime_policy" {
  name = "shopcloud-common-runtime-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          aws_secretsmanager_secret.app_secrets.arn,
          aws_db_instance.postgres_primary.master_user_secret[0].secret_arn,
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/shopcloud/${var.environment}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "common_runtime_attach" {
  for_each = aws_iam_role.pod_irsa

  role       = each.value.name
  policy_arn = aws_iam_policy.common_runtime_policy.arn
}

resource "aws_iam_policy" "checkout_runtime_policy" {
  name = "shopcloud-checkout-runtime-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl"
        ]
        Resource = aws_sqs_queue.invoice_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "checkout_runtime_attach" {
  role       = aws_iam_role.pod_irsa["checkout"].name
  policy_arn = aws_iam_policy.checkout_runtime_policy.arn
}

resource "aws_iam_policy" "catalog_runtime_policy" {
  name = "shopcloud-catalog-runtime-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.product_images_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "catalog_runtime_attach" {
  role       = aws_iam_role.pod_irsa["catalog"].name
  policy_arn = aws_iam_policy.catalog_runtime_policy.arn
}
