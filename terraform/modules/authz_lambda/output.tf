output "function_name" {
  description = "Name of lambda."
  value       = module.authz_lambda.function_name
}

output "arn" {
  description = "ARN of lambda."
  value       = module.authz_lambda.arn
}

output "iam_role_name" {
  description = "IAM Role name which can be used to invoke the lambda"
  value       = module.authz_lambda.iam_role_name
}

output "invoke_arn" {
  description = "Invoke ARN of lambda"
  value       = module.authz_lambda.invoke_arn
}

output "iam_role_arn" {
  description = "IAM Role ARN which can be used to invoke the lambda"
  value       = module.authz_lambda.iam_role_arn
}