data "aws_iam_policy_document" "iot_assume_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "iot.amazonaws.com",
      ]
      type = "Service"
    }
  }
}
