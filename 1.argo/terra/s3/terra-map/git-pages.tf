resource "rustfs_bucket" "git_pages" {
  name = "git-pages"
}
resource "random_password" "git_pages_sa_password" {
  length  = 40
  special = false
}
resource "random_password" "git_pages_admin_id" {
  length  = 20
  special = false
}

resource "rustfs_serviceaccount" "git_pages" {
  name        = "git-pages"
  description = "Service account for Git Pages"
  access_key  = random_password.git_pages_admin_id.result
  secret_key  = random_password.git_pages_sa_password.result
}

resource "rustfs_policy" "git_pages_policy" {
  name = rustfs_bucket.git_pages.name
  statement = [{
    effect    = "Allow"
    action    = ["*"]
    ressource = ["arn:aws:s3:::${rustfs_bucket.git_pages.name}/*"]
    condition = {
      string_equals = {
        "s3:username" = ["${rustfs_serviceaccount.git_pages.access_key}"]
      }
    }
  }]
}

resource "vault_kv_secret_v2" "git_pages" {
  mount = "mv"
  name  = "git-pages/s3"
  data_json = jsonencode(
    {
      access_key = random_password.git_pages_admin_id.result,
      secret_key = random_password.git_pages_sa_password.result,
      url        = "bucket.batleforc.fr"
    }
  )
}
