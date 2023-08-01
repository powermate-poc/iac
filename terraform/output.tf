output "timestream_db" {
  description = "The created timestream db"
  value = {
    db_arn        = module.timestream_db.db_arn
    db_name       = module.timestream_db.db_name
    db_table_name = module.timestream_db.db_table_name
  }
}

output "api_gateway_base_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}
output "user_registration_link" {
  description = "URL for registering a new user"
  value       = "https://${aws_cognito_user_pool_domain.end_users.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/signup?response_type=token&client_id=${aws_cognito_user_pool_client.frontend.id}&redirect_uri=${aws_api_gateway_deployment.this.invoke_url}"
}

output "authorizer_id" {
  description = "the id of the API gateway authorizer"
  value       = aws_api_gateway_authorizer.api_gateway_authorizer.id
}