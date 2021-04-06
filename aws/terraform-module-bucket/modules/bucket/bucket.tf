#-------------------------------------------------------------------------
# Bucket
#-------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket" {

  bucket = var.bucket_name
  # see alternatives at https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl
  acl = "private"

  versioning {
    enabled = var.enable_versioning
  }

  # if var.enable_server_side_encryption is true
  dynamic "server_side_encryption_configuration" {
    for_each = var.enable_server_side_encryption ? [1] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  # if var.bucket_lifecycle is not empty list []
  dynamic "lifecycle_rule" {
    for_each = { for lc in var.bucket_lifecycle : lc.id => lc }
    content {
      id      = lifecycle_rule.value.id
      enabled = true

      prefix = lifecycle_rule.value.prefix

      dynamic "transition" {
        for_each = lifecycle_rule.value.infrequent_access_days == null ? [] : [1]
        content {
          days          = lifecycle_rule.value.infrequent_access_days
          storage_class = "STANDARD_IA" # or "ONEZONE_IA"
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.infrequent_access_days == null ? [] : [1]
        content {
          days          = lifecycle_rule.value.infrequent_access_days
          storage_class = "STANDARD_IA" # or "ONEZONE_IA"
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.glacier_days == null ? [] : [1]
        content {
          days          = lifecycle_rule.value.glacier_days
          storage_class = "GLACIER"
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.glacier_days == null ? [] : [1]
        content {
          days          = lifecycle_rule.value.glacier_days
          storage_class = "GLACIER"
        }
      }

      dynamic "expiration" {
        for_each = lifecycle_rule.value.expiration_days == null ? [] : [1]
        content {
          days = lifecycle_rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.expiration_days == null ? [] : [1]
        content {
          days = lifecycle_rule.value.expiration_days
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
