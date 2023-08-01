module "authz_lambda" {
  source                 = "./modules/authz_lambda"
  project_name           = local.name
  function_name          = "authorizer"
  handler                = "powermate_${var.env}_authorizer_lambda"
  runtime                = local.go_runtime
  tags                   = local.standard_tags
  rest_api_execution_arn = module.api_gateway.execution_arn

  environment_variables = {
    REGION         = data.aws_region.current.name
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    USER_POOL_ID   = aws_cognito_user_pool.end_users.id
    API_GATEWAY_ID = "a23ypr2qzg" // //module.api_gateway.id
  }
}

data "aws_iam_policy_document" "allow_invocation_of_authz_lambda" {
  version = "2012-10-17"
  statement {
    sid    = "InvokeLambdaFunction"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.authz_lambda.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "allow-invocation-of-authz-lambda"
  description = "Permissions for the authorizer Lambda function"
  policy      = data.aws_iam_policy_document.allow_invocation_of_authz_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = module.authz_lambda.iam_role_name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}