terraform {
  required_providers {
    forgejo = {
      source = "svalabs/forgejo"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }
  }
}

variable "forgejo_token" {
  sensitive   = true
  description = "Forgejo Management Access Token"
}

variable "forgejo_management_url" {
  description = "Forgejo Management URL"
  default     = "https://git.batleforc.fr"
}

provider "forgejo" {
  alias     = "apiToken"
  host      = var.forgejo_management_url
  api_token = var.forgejo_token
  # ...or use the FORGEJO_API_TOKEN environment variable
}
