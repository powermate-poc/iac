resource "aws_iot_topic_rule" "device_data_rule" {
  name        = "${var.project_name}_${var.rule_name}"
  description = var.description
  enabled     = true
  sql         = "${var.sql_select} FROM '${var.topic}'"
  sql_version = "2016-03-23"

  sqs {
    queue_url  = var.sqs_queue_url
    role_arn   = aws_iam_role.iot_role.arn
    use_base64 = false
  }
  tags = var.tags
}