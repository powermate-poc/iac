module "authz_lambda" {
  source        = "./../lambda"
  project_name  = var.project_name
  function_name = var.function_name

  environment_variables = var.environment_variables

  handler = var.handler
  runtime = var.runtime
  tags    = var.tags
}

resource "aws_lambda_permission" "for_authz_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.authz_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.rest_api_execution_arn}/*/*"
}


