############################
### API GATEWAY ############
############################

locals {
  authorizer_name = "${local.name}_api_gateway_authorizer"
}

module "api_gateway" {
  source                = "./modules/gateway"
  project_name          = local.name
  tags                  = local.standard_tags
  cognito_user_pool_arn = aws_cognito_user_pool.end_users.arn
  api_template          = file("./../powermate-api.yml")

  api_template_vars = {

    region = var.AWS_REGION

    account_id                     = data.aws_caller_identity.current.account_id
    authorizer_name                = local.authorizer_name
    authorizer_lambda_arn          = module.authz_lambda.arn
    authorizer_lambda_iam_role_arn = module.authz_lambda.iam_role_arn

    data_api_lambda_arn         = module.data_api_lambda.arn
    passthrough_api_lambda_arn  = module.passthrough_api_lambda.arn
    provisioning_api_lambda_arn = module.provisioning_api_lambda.arn
    devices_api_lambda_arn      = module.devices_api_lambda.arn
    ingress_api_lambda_arn      = module.ingress_api_lambda.arn
  }
}

module "data_api_lambda" {
  source        = "./modules/api_lambda"
  project_name  = local.name
  function_name = "data"

  handler = "data"
  runtime = local.go_runtime

  tags = local.standard_tags

  rest_api_execution_arn = module.api_gateway.execution_arn
}

module "ingress_api_lambda" {
  source        = "./modules/api_lambda"
  project_name  = local.name
  function_name = "ingress"

  handler = "ingress"
  runtime = local.go_runtime

  tags = local.standard_tags

  rest_api_execution_arn = module.api_gateway.execution_arn
}

module "devices_api_lambda" {
  source        = "./modules/api_lambda"
  project_name  = local.name
  function_name = "devices"

  handler = "devices"
  runtime = local.go_runtime

  tags = local.standard_tags

  rest_api_execution_arn = module.api_gateway.execution_arn
}

module "passthrough_api_lambda" {
  source        = "./modules/api_lambda"
  project_name  = local.name
  function_name = "passthrough"

  handler = "passthrough"
  runtime = local.go_runtime

  tags = local.standard_tags

  rest_api_execution_arn = module.api_gateway.execution_arn
}

module "provisioning_api_lambda" {
  source        = "./modules/api_lambda"
  project_name  = local.name
  function_name = "provisioning"

  handler = "provisioning"
  runtime = local.go_runtime

  tags = local.standard_tags

  environment_variables = {
    THING_POLICY_NAME = aws_iot_policy.for_thing_pub_clientId.name
  }

  rest_api_execution_arn = module.api_gateway.execution_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = module.api_gateway.id
  description = "Powermate API deployed at ${timestamp()}"

  variables = {
    deployed_at = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {
  name                   = local.authorizer_name
  rest_api_id            = module.api_gateway.id
  authorizer_uri         = module.authz_lambda.invoke_arn
  authorizer_credentials = module.authz_lambda.iam_role_arn
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
}

resource "aws_api_gateway_stage" "this" {
  stage_name = "api"

  rest_api_id   = module.api_gateway.id
  deployment_id = aws_api_gateway_deployment.this.id

  tags = local.standard_tags
}


############################################################################
#### attach policy that grants ingress_api_lambda write access to SQS #######
############################################################################
resource "aws_iam_role_policy_attachment" "for_ingress_api_lambda_timestream" {
  policy_arn = module.ingress_endpoint_sqs.policies.for_iot_topic
  role       = module.ingress_api_lambda.iam_role_name
}

###################################################################
####### attach policy for data_api_lambda to access timestream ####
###################################################################
resource "aws_iam_role_policy_attachment" "for_data_api_lambda_timestream" {
  policy_arn = module.timestream_db.policies.for_data_api_lambda
  role       = module.data_api_lambda.iam_role_name
}

###################################################################
####### attach policy for passthrough_api_lambda to access timestream ####
###################################################################
resource "aws_iam_role_policy_attachment" "for_passthrough_api_lambda_timestream" {
  policy_arn = module.timestream_db.policies.for_data_api_lambda
  role       = module.passthrough_api_lambda.iam_role_name
}

###################################################################
####### attach policy for provisioning_api_lambda to handle things ####
###################################################################
resource "aws_iam_role_policy_attachment" "for_provisioning_api_lambda_thing" {
  policy_arn = aws_iam_policy.for_provisioning_api_lambda.arn
  role       = module.provisioning_api_lambda.iam_role_name
}

###################################################################
####### attach policy for devices_api_lambda to list things ####
###################################################################
resource "aws_iam_role_policy_attachment" "for_devices_api_lambda_thing" {
  policy_arn = aws_iam_policy.for_devices_api_lambda.arn
  role       = module.devices_api_lambda.iam_role_name
}
