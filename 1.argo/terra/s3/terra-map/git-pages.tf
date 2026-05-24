resource "minio_s3_bucket" "git_pages" {
  bucket        = "git-pages"
  acl           = "private"
  force_destroy = true
}

resource "minio_iam_user" "git_pages_user" {
  name          = "git-pages-user"
  force_destroy = true
}

resource "minio_iam_service_account" "git_pages_service_account" {
  target_user = minio_iam_user.git_pages_user.name
}
