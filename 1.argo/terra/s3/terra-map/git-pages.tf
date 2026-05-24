resource "rustfs_bucket" "git_pages" {
  bucket = "git-pages"
}
resource "random_password" "git_pages_sa_password" {
  length           = 42
  special          = true
  override_special = "_-"
}
resource "random_password" "git_pages_admin_id" {
  length           = 42
  special          = true
  override_special = "_-"
}

resource "rustfs_serviceaccount" "git_pages" {
  name       = "git-pages"
  access_key = random_password.git_pages_admin_id.result
  secret_key = random_password.git_pages_sa_password.result
}

resource "rustfs_bucket_policy" "git_pages_policy" {
  bucket = rustfs_bucket.git_pages.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["*"],
      "Resource": ["arn:aws:s3:::${rustfs_bucket.git_pages.bucket}/*"],
      "Condition": {
        "StringEquals": {
          "s3:username": ["${rustfs_serviceaccount.git_pages.access_key}"]
        }
      }
    }
  ]
}
EOF
}
