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
  type = list(object({ # empty list [] for disabling lifecycles
    id                     = string
    prefix                 = string
    infrequent_access_days = number # 50% price of standard, null for disabling
    glacier_days           = number # 20% price of standard, null for disabling
    expiration_days        = number # deletion, null for disabling
  }))
  default = [{
    id                     = "all"
    prefix                 = "*"
    infrequent_access_days = 30  # 50% price of standard, null for disabling
    glacier_days           = 60  # 20% price of standard, null for disabling
    expiration_days        = 365 # deletion, null for disabling
  }]
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
