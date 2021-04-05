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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_policy" "policy" {

#   bucket   = aws_s3_bucket.bucket.id

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression's result to valid JSON syntax.
#   policy = templatefile("iam/policy.json.tpl", {
#     arn_allowed_PutObject = jsonencode(var.arn_allowed_PutObject)
#     bucket_arn            = each.value.arn
#   })
# }
