terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.12.5"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.13.0"
    }
  }
}

locals {
  token_vault = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
}

variable "vault_addr" {
  type        = string
  description = "The address of the Vault instance"
  default     = "https://vault.capi.weebo.poc"
}

variable "username" {
  type    = string
  default = "admin"
}

provider "vault" {
  address          = var.vault_addr
  ca_cert_file     = "/etc/ssl/vault/ca.crt"
  skip_child_token = "true"
  auth_login_jwt {
    role  = "registry"
    jwt   = local.token_vault
    mount = "kubernetes"
  }
}

provider "harbor" {
  url      = "https://registry.batleforc.fr"
  username = var.username
  password = ephemeral.vault_kv_secret_v2.harbor_config.data.HARBOR_ADMIN_PASSWORD
}
