resource "rustfs_bucket" "git_pages" {
  name = "git-pages"
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

resource "rustfs_policy" "git_pages_policy" {
  name = rustfs_bucket.git_pages.name
  statement = [{
    effect   = "Allow"
    action   = ["*"]
    resource = ["arn:aws:s3:::${rustfs_bucket.git_pages.name}/*"]
    condition = {
      string_equals = {
        "s3:username" = ["${rustfs_policy.git_pages.access_key}"]
      }
    }
  }]
}
