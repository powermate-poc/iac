variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
}

variable "rule_name" {
  type        = string
  description = "The name of the rule. Being used for naming of infrastructure components."
}

variable "description" {
  type        = string
  description = "Description of the iot topic rule."
}

variable "sql_select" {
  type        = string
  description = "The SQL to be executed"
}

variable "topic" {
  type        = string
  description = "The topic which this rule applies to"
}

variable "sqs_queue_url" {
  description = "sqs queue url and use_base64 are supported arguments"
  type        = string
}

variable "tags" {
  description = "key value pairs of tags to be used for resources created in this module"
  type        = map(string)
  default     = {}
}