variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
}

variable "sqs_name" {
  type        = string
  description = "The purpose of this aws simple queue service resource. Being used for naming of infrastructure components."
}

variable "tags" {
  description = "key value pairs of tags to be used for resources created in this module"
  type        = map(string)
  default     = {}
}