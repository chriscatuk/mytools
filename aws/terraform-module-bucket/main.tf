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

data "aws_caller_identity" "current" {}

module "buckets" {
  source      = "./modules/bucket"
  for_each    = toset(var.bucket_names_list)
  bucket_name = "${var.env}-${each.key}"

  enable_versioning             = var.enable_versioning
  enable_server_side_encryption = var.enable_server_side_encryption
  bucket_lifecycle              = var.bucket_lifecycle

  tags = var.tags
}

resource "aws_s3_bucket_policy" "policy" {

  for_each = module.buckets
  bucket   = each.value.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = templatefile("iam/policy.json.tpl", {
    arn_allowed_PutObject = jsonencode([
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/S3Access"
    ])
    bucket_arn = each.value.arn
  })
}
