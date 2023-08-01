data "aws_iam_policy_document" "for_ingress_lambda" {
  version = "2012-10-17"
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = [aws_sqs_queue.this.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }
}

data "aws_iam_policy_document" "for_iot_core" {
  version = "2012-10-17"
  statement {
    sid       = "AllowSQSSend"
    effect    = "Allow"
    resources = [aws_sqs_queue.this.arn]
    actions   = ["sqs:SendMessage"]
  }
}