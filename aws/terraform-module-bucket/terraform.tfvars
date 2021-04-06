bucket_names_list = [
  "example-for-chris1-wip",
  "example-for-chris2-wip"
]

env    = "dev"
region = "eu-west-1"

enable_versioning             = true
enable_server_side_encryption = true
bucket_lifecycle = [{           # empty list [] for disabling lifecycles
  id                     = "all"
  prefix                 = null # null for all bucket
  infrequent_access_days = null # 50% price of standard, null for disabling
  glacier_days           = 30   # 20% price of standard, null for disabling
  expiration_days        = 365  # deletion, null for disabling
}]

tags = {
  env     = "dev"
  purpose = "temporary"
}
