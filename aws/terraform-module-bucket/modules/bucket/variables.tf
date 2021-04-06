
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
  type = list(object({
    id                     = string
    prefix                 = string
    infrequent_access_days = number
    glacier_days           = number
    expiration_days        = number
  }))
  default = [{
    id                     = "all"
    prefix                 = "*"
    infrequent_access_days = 30 # cannot be smaller than 30
    glacier_days           = 60
    expiration_days        = 365
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


