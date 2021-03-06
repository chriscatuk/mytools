
variable "bucket_name" {
  description = "List of buckets to create"
  type        = string
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
    prefix                 = string # null for all bucket
    infrequent_access_days = number # 50% price of standard, null for disabling
    glacier_days           = number # 20% price of standard, null for disabling
    expiration_days        = number # deletion, null for disabling
  }))
  default = [{ # empty list [] for disabling lifecycles
    id                     = "all"
    prefix                 = null # null for all bucket
    infrequent_access_days = 30   # 50% price of standard
    glacier_days           = 60   # 20% price of standard
    expiration_days        = 365  # deletion
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


