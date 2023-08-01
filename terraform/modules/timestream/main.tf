locals {
  name = "${var.project_name}_timestream"
}

resource "aws_timestreamwrite_database" "main" {
  database_name = local.name
  tags          = var.tags
}

resource "aws_timestreamwrite_table" "main" {
  database_name = aws_timestreamwrite_database.main.database_name
  table_name    = "${local.name}_table"

  # Define the table schema
  retention_properties {
    # The number of hours that data is retained in the table's memory store. 
    # After this period, the data is moved to the magnetic store. 
    # The memory store is used for faster access to recent data, 
    # while the magnetic store is used for less frequently accessed data.
    memory_store_retention_period_in_hours = var.memory_store_retention_period_in_hours
    # The number of days that data is retained in the table's magnetic store. 
    # After this period, the data is deleted.
    magnetic_store_retention_period_in_days = var.magnetic_store_retention_period_in_days
  }
  tags = var.tags
}

resource "aws_iam_policy" "for_ingress_endpoint" {
  name        = "${local.name}_ingress_endpoint_lambda_access"
  description = "IAM policy to be used to grant ingress endpoint lambda WRITE access to timestream db '${aws_timestreamwrite_database.main.database_name}'"
  policy      = data.aws_iam_policy_document.for_ingress_endpoint.json
  tags        = var.tags
}

resource "aws_iam_policy" "for_data_api_lambda" {
  name        = "${local.name}_data_api_lambda_access"
  description = "IAM policy to be used to grant api lambda READ access to timestream db '${aws_timestreamwrite_database.main.database_name}'"
  policy      = data.aws_iam_policy_document.for_data_api_lambda.json
  tags        = var.tags
}