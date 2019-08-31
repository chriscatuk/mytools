variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
}

variable "region" {
  description = "Region to deploy lambda in"
}

variable "function_name" {
  description = "Name used for the function and roles"
  default     = "tgw-connectivity-data-gathering"
}

variable "runtime" {
  description = "Runtime used by lambda"
  default     = "python3.7"
}

variable "timeout" {
  description = "Timeout of the lambda function in seconds (up to 900s)"
}

variable "memory_size" {
  description = "Memory allocated to the lambda runtime, in MB"
}

variable "assumedRoleName" {
  description = "Name of the existing Role to assume in the attached VPC accounts. (ex: role/service-role/tgw-test-role)"
  type        = "string"
}

variable "lambdaRoleName" {
  description = "Name of the existing Role used by Lambda, role/service-role/ will be added as prefix later. (ex: tgw-test-role)"
  type        = "string"
}
