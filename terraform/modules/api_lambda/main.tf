module "api_lambda" {
  source        = "./../lambda"
  project_name  = var.project_name
  function_name = "${var.function_name}_api"

  environment_variables = var.environment_variables

  handler = var.handler
  runtime = var.runtime
  tags    = var.tags
}

resource "aws_lambda_permission" "for_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${var.rest_api_execution_arn}/*/*"
}