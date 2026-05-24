resource "minio_iam_policy" "test_policy" {
  name   = "weebo_admin_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["admin:*"],
      "Resource": ["arn:aws:s3:::*"],
      "Condition": {
        "ForAnyValue:StringEquals": {
          "jwt:groups": ["weebo_admin"]
        }
      }
    }
  ]
}
EOF
}

resource "minio_iam_group" "weebo_admin" {
  name = "weebo_admin"
}
