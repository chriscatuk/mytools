terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.26"
    }
  }
}

provider "aws" {
  region = var.region
}

module "buckets" {
  source      = "./modules/bucket"
  for_each    = { for bucketname in var.bucket_names_list : bucketname => bucketname }
  bucket_name = "${var.env}-${each.value}"

  enable_versioning     = var.enable_versioning
  bucket_lifecycle      = var.bucket_lifecycle
  arn_allowed_PutObject = var.arn_allowed_PutObject

  tags = var.tags
}
