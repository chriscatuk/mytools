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
  description = "Timeout of the lambda function in seconds"
  default     = 70
}

variable "memory_size" {
  description = "Memory allocated to the lambda runtime, in MB"
  default     = 128
}
