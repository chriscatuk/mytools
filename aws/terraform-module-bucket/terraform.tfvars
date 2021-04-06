bucket_names_list = [
  "example-for-chris1-wip",
  "example-for-chris2-wip"
]

env    = "dev"
region = "eu-west-1"

enable_versioning             = true
enable_server_side_encryption = true
bucket_lifecycle = [{
  id                     = "all"
  prefix                 = "*"
  infrequent_access_days = 30 # cannot be smaller than 30
  glacier_days           = 60
  expiration_days        = 365
}]

arn_allowed_PutObject = []

tags = {
  env     = "dev"
  purpose = "temporary"
}
