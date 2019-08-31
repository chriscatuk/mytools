terraform {
  required_version = ">= 0.11.14"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

locals {
  lambda-package-dir = "${path.cwd}/lambda_pkg_${random_string.name.result}"
  lambda-package-file = "lambda_${random_string.name.result}.zip"
}


resource "null_resource" "install_python_dependencies" {
  triggers {
    always       = "${timestamp()}"
    handler      = "${base64sha256(file("${path.module}/lambdas/handler.py"))}"
    requirements = "${base64sha256(file("${path.module}/lambdas/requirements.txt"))}"
    build        = "${base64sha256(file("${path.module}/lambdas/build.sh"))}"
  }
  
  provisioner "local-exec" {
    command = "bash ${path.module}/lambdas/build.sh"

    environment {
      source_code_path = "${path.module}/lambdas"
      path_cwd         = "${path.cwd}"
      path_module      = "${path.module}"
      runtime          = "${var.runtime}"
      function_name    = "${var.function_name}"
      lambda_dir_name  = "${local.lambda-package-dir}"
    }
  }
}

data "archive_file" "lambda" {
  depends_on  = ["null_resource.install_python_dependencies"]
  type        = "zip"
  source_dir  = "${local.lambda-package-dir}"
  output_path = "${local.lambda-package-file}"
}

data "template_file" "policydocument" {
  template = "${file("${path.module}/policies/policy.json.tpl")}"

  vars = {
    aws_region      = "${data.aws_region.current.name}"
    account_id      = "${data.aws_caller_identity.current.account_id}"
    assumedRoleName = "${var.assumedRoleName}"
  }
}

resource "aws_iam_role" "monitoring_connectivity_iam_role" {
  name = "${var.lambdaRoleName}"
  path = "/service-role/"

  assume_role_policy = "${file("${path.module}/policies/policy-assume.json")}"
}

resource "aws_iam_policy" "monitoring_connectivity_iam_policy" {
  name   = "${var.lambdaRoleName}"
  policy = "${data.template_file.policydocument.rendered}"
}

resource "aws_iam_role_policy_attachment" "monitoring_connectivity" {
  role       = "${aws_iam_role.monitoring_connectivity_iam_role.name}"
  policy_arn = "${aws_iam_policy.monitoring_connectivity_iam_policy.arn}"
}

resource "aws_lambda_function" "monitoring_connectivity" {
  filename      = "${data.archive_file.lambda.output_path}"
  source_code_hash = "${data.archive_file.lambda.output_base64sha256}"
  function_name = "${var.function_name}"
  role          = "${aws_iam_role.monitoring_connectivity_iam_role.arn}"
  handler       = "handler.lambda_handler"

  timeout     = "${var.timeout}"
  memory_size = "${var.memory_size}"
  runtime     = "${var.runtime}"
  tags        = "${var.tags}"
  environment {
    variables = {
      AssumedRoleName = "${var.assumedRoleName}"
    }
  }
}
