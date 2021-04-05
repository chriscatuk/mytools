output "arn" {
  value = aws_s3_bucket.bucket.arn
}

# TODO: don't keep this one for final version
output "bucket_troubleshooting" {
  value = aws_s3_bucket.bucket
}
