variable "AWS_ACCESS_KEY" {
  type        = string
  description = "access key for aws user"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "access key for aws user"
}

variable "AWS_REGION" {
  type        = string
  description = "region"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC being used"
  default     = "10.0.0.0/16"
}


variable "project_name" {
  type        = string
  description = "The name of the project. Being used for naming of infrastructure components."
  default     = "powermate"
}

variable "env" {
  type = string
}
