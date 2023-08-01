output "db_name" {
  description = "The name of the created database"
  value       = aws_timestreamwrite_database.main.database_name
}

output "db_table_name" {
  description = "The name of the created table"
  value       = aws_timestreamwrite_table.main.table_name
}

output "db_arn" {
  description = "The ARN of the created database"
  value       = aws_timestreamwrite_database.main.arn
}

output "policies" {
  description = "ARN's of the created policies to be used to access this timestream db"
  value = {
    for_ingress_lambda  = aws_iam_policy.for_ingress_endpoint.arn
    for_data_api_lambda = aws_iam_policy.for_data_api_lambda.arn
  }
}