output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "id" {
  value = aws_s3_bucket.bucket.id
}

# TODO: don't keep this one for final version
output "bucket_troubleshooting" {
  value = aws_s3_bucket.bucket
}
