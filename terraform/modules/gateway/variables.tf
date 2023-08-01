variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "ARN of the cognito user pool being used to authorize to this gateway"
}

variable "tags" {
  description = "key value pairs of tags to be used for resources created in this module"
  type        = map(string)
  default     = {}
}

variable "api_template" {
  description = "API Gateway OpenAPI 3 template file"
}

variable "api_template_vars" {
  description = "Variables required in the OpenAPI template file"
  type        = map(string)
}
