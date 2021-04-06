#----------------------------------------
# Env and region must always be provided
#----------------------------------------
variable "env" {
  description = "Environment name, such as prod, test, dev..."
  type        = string
}

variable "region" {
  description = "AWS Region, such as eu-west-1 or us-east-1"
  type        = string
}

variable "bucket_names_list" {
  description = "List of buckets to create"
  type        = list(string)
}

variable "enable_versioning" {
  description = "If true, the bucket will enable versioning"
  type        = bool
  default     = false
}

variable "enable_server_side_encryption" {
  description = "If true, the bucket will enable server side encryption"
  type        = bool
  default     = false
}

variable "bucket_lifecycle" {
  description = "Number of days before files are moved to glacier or deleted"
  type = list(object({
    prefix        = string
    glacier_days  = number
    deletion_days = number
  }))
  default = [{
    prefix        = "*"
    glacier_days  = 31
    deletion_days = 365
  }]
}

variable "arn_allowed_PutObject" {
  description = "List of AWS Principals (arn) autorised to putObject into the bucket"
  type        = list(string)
  default     = []
}

variable "bucket_backup" {
  description = "Not used yet. Would be used to enable a backup or a replication."
  type        = any
  default     = null
}

variable "tags" {
  description = "Not used yet. Would be used to enable a backup or a replication."
  type        = map(string)
}
