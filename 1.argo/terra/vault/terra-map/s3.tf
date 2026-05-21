resource "random_password" "S3_ADMIN_PASSWORD" {
  length           = 42
  special          = true
  override_special = "_-"
}

resource "random_password" "S3_ADMIN_ID" {
  length           = 42
  special          = true
  override_special = "_-"
}

resource "vault_kv_secret_v2" "S3" {
  mount = vault_mount.main-vault.path
  name  = "s3/config"
  data_json = jsonencode(
    {
      S3_ADMIN_PASSWORD = random_password.S3_ADMIN_PASSWORD.result,
      S3_ADMIN_ID       = random_password.S3_ADMIN_ID.result,
    }
  )
}
