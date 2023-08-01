variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
}

variable "memory_store_retention_period_in_hours" {
  type        = number
  description = "The number of hours that data is retained in the table's memory store. After this period, the data is moved to the magnetic store. The memory store is used for faster access to recent data, while the magnetic store is used for less frequently accessed data."
  default     = 24
}

variable "magnetic_store_retention_period_in_days" {
  type        = number
  description = "The number of days that data is retained in the table's magnetic store. After this period, the data is deleted."
  default     = 7
}

variable "tags" {
  description = "key value pairs of tags to be used for resources created in this module"
  type        = map(string)
  default     = {}
}