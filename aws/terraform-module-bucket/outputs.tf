output "buckets" {
  description = "Return all the outputs from the module"
  value       = { for bucket in module.buckets : bucket.id => bucket.arn }
}
