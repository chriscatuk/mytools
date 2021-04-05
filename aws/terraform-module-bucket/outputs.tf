output "buckets" {
  value = { for bucket in module.buckets : bucket.arn => bucket.arn }
}

# TODO: don't keep this one for final version
output "bucket_troubleshooting" {
  value = module.buckets
}
