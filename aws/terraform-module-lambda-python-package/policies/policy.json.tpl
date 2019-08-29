{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": [
          "arn:aws:logs:${aws_region}:${account_id}:log-group:/aws/lambda/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeVpcs",
          "ec2:DescribeRegions",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables"
        ],
        "Resource": "*"
      }
    ]
  }