resource "aws_sqs_queue" "invoice_dlq" {
  name                      = "shopcloud-invoice-dlq-${var.environment}"
  message_retention_seconds = 604800

  tags = {
    Name        = "shopcloud-invoice-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "invoice_queue" {
  name                       = "shopcloud-invoice-queue-${var.environment}"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.invoice_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name        = "shopcloud-invoice-queue"
    Environment = var.environment
  }
}
