output "lambda_arn" {
  value = "${aws_lambda_function.monitoring_connectivity.arn}"
}

output "role_arn" {
  value = "${aws_iam_role.monitoring_connectivity_iam_role.arn}"
}
