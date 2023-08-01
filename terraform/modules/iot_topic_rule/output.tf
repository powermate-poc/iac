output "iam_role_name" {
  description = "The IAM role to be assumed by AWS IOT"
  value       = aws_iam_role.iot_role.name
}