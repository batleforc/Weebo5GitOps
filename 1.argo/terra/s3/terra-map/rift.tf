# Rift of Sym's release store: CI pushes every tag under releases/<version>/, the hub
# serves the launcher from it and writes bug-report replays into it.
resource "rustfs_bucket" "rift" {
  name = "rift-of-sym"
}

# The hub: reads, publishes, prunes, stores replays — the whole bucket.
resource "rustfs_policy" "rift_hub" {
  name = "rift-hub"
  statement = [{
    effect    = "Allow"
    action    = ["s3:*"]
    ressource = ["arn:aws:s3:::${rustfs_bucket.rift.name}", "arn:aws:s3:::${rustfs_bucket.rift.name}/*"]
  }]
}

# CI (release.yml, `task boot:push`): writes releases/ and nothing else. ListBucket and
# GetObject because `aws s3 sync` compares against what is already there.
resource "rustfs_policy" "rift_ci" {
  name = "rift-ci"
  statement = [
    {
      effect    = "Allow"
      action    = ["s3:ListBucket"]
      ressource = ["arn:aws:s3:::${rustfs_bucket.rift.name}"]
    },
    {
      effect    = "Allow"
      action    = ["s3:PutObject", "s3:GetObject"]
      ressource = ["arn:aws:s3:::${rustfs_bucket.rift.name}/releases/*"]
    },
  ]
}

resource "random_password" "rift_hub_id" {
  length  = 20
  special = false
}
resource "random_password" "rift_hub_secret" {
  length  = 40
  special = false
}
resource "random_password" "rift_ci_id" {
  length  = 20
  special = false
}
resource "random_password" "rift_ci_secret" {
  length  = 40
  special = false
}

resource "rustfs_user" "rift_hub" {
  access_key = random_password.rift_hub_id.result
  secret_key = random_password.rift_hub_secret.result
  policy     = rustfs_policy.rift_hub.name
}

resource "rustfs_user" "rift_ci" {
  access_key = random_password.rift_ci_id.result
  secret_key = random_password.rift_ci_secret.result
  policy     = rustfs_policy.rift_ci.name
}

# HUB_S3_* are synced into the risym namespace by an ExternalSecret; AWS_* are copied by
# hand into the GitHub repository secrets of rift-of-sym.
resource "vault_kv_secret_v2" "rift" {
  mount = "mv"
  name  = "risym/s3"
  data_json = jsonencode(
    {
      HUB_S3_ACCESS_KEY     = random_password.rift_hub_id.result,
      HUB_S3_SECRET_KEY     = random_password.rift_hub_secret.result,
      AWS_ACCESS_KEY_ID     = random_password.rift_ci_id.result,
      AWS_SECRET_ACCESS_KEY = random_password.rift_ci_secret.result,
    }
  )
}
