output "sqs_name" {
  description = "Name of sqs queue."
  value       = aws_sqs_queue.this.name
}

output "sqs_arn" {
  description = "ARN of sqs queue."
  value       = aws_sqs_queue.this.arn
}

output "sqs_queue_url" {
  description = "URL of sqs queue."
  value       = aws_sqs_queue.this.url
}

output "policies" {
  description = "ARN's of policies to be used to access this SQS"
  value = {
    for_ingress_lambda = aws_iam_policy.for_ingress_lambda.arn
    for_iot_topic      = aws_iam_policy.for_iot_topic.arn
  }
}