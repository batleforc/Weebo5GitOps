# weebo-kura's chunk store: encrypted, deduplicated note chunks. Read through
# Vault (mv/kura/s3, policy kura-server) by kura-server in the kura namespace.
resource "rustfs_bucket" "kura" {
  name = "kura"
}

resource "rustfs_policy" "kura" {
  name = "kura"
  statement = [{
    effect    = "Allow"
    action    = ["s3:*"]
    ressource = ["arn:aws:s3:::${rustfs_bucket.kura.name}", "arn:aws:s3:::${rustfs_bucket.kura.name}/*"]
  }]
}

resource "random_password" "kura_id" {
  length  = 20
  special = false
}
resource "random_password" "kura_secret" {
  length  = 40
  special = false
}

resource "rustfs_user" "kura" {
  access_key = random_password.kura_id.result
  secret_key = random_password.kura_secret.result
  policy     = rustfs_policy.kura.name
}

# Keys as kura-server expects them (camelCase); always path-style.
resource "vault_kv_secret_v2" "kura" {
  mount = "mv"
  name  = "kura/s3"
  data_json = jsonencode(
    {
      endpoint        = "http://rustfs-svc.s3.svc.cluster.local:9000",
      bucket          = rustfs_bucket.kura.name,
      region          = "us-east-1",
      accessKeyId     = random_password.kura_id.result,
      secretAccessKey = random_password.kura_secret.result,
    }
  )
}
