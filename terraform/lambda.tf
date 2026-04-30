data "aws_iam_policy_document" "invoice_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invoice_lambda_role" {
  name               = "shopcloud-invoice-lambda-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.invoice_lambda_assume_role.json
}

resource "aws_iam_role_policy" "invoice_lambda_policy" {
  name = "shopcloud-invoice-lambda-policy-${var.environment}"
  role = aws_iam_role.invoice_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.invoice_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.invoice_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/lambda.py"
  output_path = "${path.module}/src/lambda.zip"
}

resource "aws_lambda_function" "invoice_pdf_lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "shopcloud-invoice-pdf-generator-${var.environment}"
  role             = aws_iam_role.invoice_lambda_role.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "lambda.lambda_handler"
  runtime = "python3.10"
  timeout = 30

  environment {
    variables = {
      INVOICE_BUCKET   = aws_s3_bucket.invoice_bucket.bucket
      SES_SENDER_EMAIL = var.ses_sender_email
    }
  }

  tags = {
    Name        = "shopcloud-invoice-pdf-lambda"
    Environment = var.environment
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn                   = aws_sqs_queue.invoice_queue.arn
  function_name                      = aws_lambda_function.invoice_pdf_lambda.arn
  batch_size                         = 10
  enabled                            = true
  maximum_batching_window_in_seconds = 5
}
