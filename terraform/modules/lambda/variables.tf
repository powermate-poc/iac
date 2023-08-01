variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
}

variable "function_name" {
  type        = string
  description = "The purpose of this aws simple queue service ressource. Being used for naming of infrastructure components."
}

variable "environment_variables" {
  description = "key value pairs of environment variables"
  type        = map(string)
  default     = {}
}

variable "handler" {
  type        = string
  description = "handler for lambda"
}

variable "runtime" {
  type        = string
  description = "runtime for lambda"
}

variable "tags" {
  description = "key value pairs of tags to be used for resources created in this module"
  type        = map(string)
  default     = {}
}