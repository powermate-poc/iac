locals {
  name = "${var.project_name}_${var.function_name}_lambda"
}



resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_role_for_${local.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}



resource "aws_lambda_function" "lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/function.zip"
  function_name = local.name
  role          = aws_iam_role.iam_for_lambda.arn

  handler = var.handler
  runtime = var.runtime

  environment {
    variables = var.environment_variables
  }
  tags = var.tags
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
  tags              = var.tags
}



resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_${local.name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
