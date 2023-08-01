output "function_name" {
  description = "Name of lambda."
  value       = aws_lambda_function.lambda.function_name
}

output "arn" {
  description = "ARN of lambda."
  value       = aws_lambda_function.lambda.arn
}

output "iam_role_name" {
  description = "IAM Role name of lambda"
  value       = aws_iam_role.iam_for_lambda.name
}
output "iam_role_arn" {
  description = "IAM Role ARN of lambda"
  value       = aws_iam_role.iam_for_lambda.arn
}

output "invoke_arn" {
  description = "Invoke ARN of lambda"
  value       = aws_lambda_function.lambda.invoke_arn
}