// Data Ingress Endpoint: IoT Core -> SQS -> Lambda
module "ingress_endpoint_sqs" {
  source       = "./modules/sqs"
  project_name = local.name
  sqs_name     = "ingress_endpoint"
  tags         = local.standard_tags

}

module "ingress_endpoint_lambda" {
  source        = "./modules/lambda"
  project_name  = local.name
  function_name = "ingress_endpoint"

  handler = "index.handler"
  runtime = local.js16_runtime

  environment_variables = {
    DATABASE = module.timestream_db.db_name
    TABLE    = module.timestream_db.db_table_name
  }
  tags = local.standard_tags
}



module "ingress_endpoint_topic_rule" {
  source = "./modules/iot_topic_rule"

  description   = "All MQTT messages from '#' go yeet into the SQS"
  project_name  = local.name
  rule_name     = "device_sensor_data"
  sql_select    = "SELECT * as message, clientId() as clientId, topic() as topic, timestamp() as timestamp_received"
  topic         = "#"
  sqs_queue_url = module.ingress_endpoint_sqs.sqs_queue_url
  tags          = local.standard_tags
}

resource "aws_lambda_event_source_mapping" "ingress_endpoint_trigger" {
  event_source_arn                   = module.ingress_endpoint_sqs.sqs_arn
  enabled                            = true
  function_name                      = module.ingress_endpoint_lambda.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 30
}

############################################################################
#### attach policy that grants Ingress Endpoint Lambda access to SQS #######
############################################################################
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy" {
  policy_arn = module.ingress_endpoint_sqs.policies.for_ingress_lambda
  role       = module.ingress_endpoint_lambda.iam_role_name
}

###################################################################################
#### attach policy that grants Ingress Endpoint Lambda access to timestream #######
###################################################################################
resource "aws_iam_role_policy_attachment" "lambda_timestream_policy" {
  policy_arn = module.timestream_db.policies.for_ingress_lambda
  role       = module.ingress_endpoint_lambda.iam_role_name
}

################################################################
#### attach policy that grants IOT topic rule access to SQS ####
################################################################
resource "aws_iam_role_policy_attachment" "iot_sqs_policy" {
  policy_arn = module.ingress_endpoint_sqs.policies.for_iot_topic
  role       = module.ingress_endpoint_topic_rule.iam_role_name
}