output "function_name" {
  description = "Name of lambda."
  value       = module.api_lambda.function_name
}

output "arn" {
  description = "ARN of lambda."
  value       = module.api_lambda.arn
}

output "iam_role_name" {
  description = "IAM Role name of lambda"
  value       = module.api_lambda.iam_role_name
}

output "invoke_arn" {
  description = "Invoke ARN of lambda"
  value       = module.api_lambda.invoke_arn
}

