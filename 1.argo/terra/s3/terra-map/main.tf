terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.0.0"
    }
    # rustfs = {
    #   source  = "weinmann-emt/rustfs"
    #   version = "0.0.6"
    # }
  }
}

locals {
  token_vault = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
}

variable "s3_token" {
  sensitive   = true
  description = "S3 Management Access Token"
}

variable "s3_id" {
  description = "S3 Management ID"
  default     = "https://vpn.batleforc.fr"
}

variable "s3_addr" {
  description = "S3 Address"
  default     = "bucket.batleforc.fr"
}

variable "vault_addr" {
  description = "Vault Address"
  default     = "https://vault.vault:8200"
}

provider "vault" {
  address          = var.vault_addr
  ca_cert_file     = "/etc/ssl/vault/ca.crt"
  skip_child_token = "true"
  auth_login_jwt {
    role  = "vpn"
    jwt   = local.token_vault
    mount = "kubernetes"
  }
}

provider "minio" {
  minio_server   = var.s3_addr
  minio_user     = var.s3_id
  minio_password = var.s3_token
}
