output "id" {
  description = "ID of api gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "root_resource_id" {
  description = "id of root resource of api"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "execution_arn" {
  description = "execution arn of api"
  value       = aws_api_gateway_rest_api.this.execution_arn
}