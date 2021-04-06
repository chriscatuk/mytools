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

  dynamic "server_side_encryption_configuration" {
    # this bloc is added only if enable_server_side_encryption is true
    for_each = var.enable_server_side_encryption ? [1] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
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
