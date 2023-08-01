data "aws_iam_policy_document" "for_ingress_endpoint" {
  version = "2012-10-17"
  statement {
    sid       = "AllowTableWriteAccess"
    effect    = "Allow"
    resources = [aws_timestreamwrite_table.main.arn]
    actions = [
      "timestream:WriteRecords"
    ]
  }
  statement {
    sid       = "AllowDatabaseAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "timestream:DescribeEndpoints",
    ]
  }
}


data "aws_iam_policy_document" "for_data_api_lambda" {
  version = "2012-10-17"
  statement {
    sid       = "AllowTableReadAccess"
    effect    = "Allow"
    resources = [aws_timestreamwrite_table.main.arn]
    actions = [
      "timestream:Select",
      "timestream:DescribeTable",
      "timestream:ListMeasures",
    ]
  }
  statement {
    sid       = "AllowDatabaseAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "timestream:DescribeEndpoints",
      "timestream:SelectValues",
      "timestream:CancelQuery"
    ]
  }
}