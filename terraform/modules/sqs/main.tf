locals {
  name = "${var.project_name}_${var.sqs_name}_sqs"
}

resource "aws_sqs_queue" "this" {
  name = local.name
  tags = var.tags
}

resource "aws_iam_policy" "for_ingress_lambda" {
  name        = "${local.name}_ingress_endpoint_lambda_access"
  description = "IAM policy to grant ingress endpoint lambda access to SQS '${aws_sqs_queue.this.name}'"
  policy      = data.aws_iam_policy_document.for_ingress_lambda.json
  tags        = var.tags

}


resource "aws_iam_policy" "for_iot_topic" {
  name        = "${local.name}_forwardmessage"
  description = "IAM policy to grant IOT topic WRITE access to SQS '${aws_sqs_queue.this.name}'"
  policy      = data.aws_iam_policy_document.for_iot_core.json
  tags        = var.tags
}