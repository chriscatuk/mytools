bucket_names_list = [
  "example-for-chris1-wip",
  "example-for-chris2-wip"
]

env    = "dev"
region = "eu-west-1"

enable_versioning             = true
enable_server_side_encryption = true
bucket_lifecycle = [{
  prefix        = "*"
  glacier_days  = 31
  deletion_days = 365
}]

arn_allowed_PutObject = []

tags = {
  env     = "dev"
  purpose = "temporary"
}
