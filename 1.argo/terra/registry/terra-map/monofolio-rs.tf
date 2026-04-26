resource "harbor_project" "monofolio-rs" {
  name                 = "monofolio-rs"
  public               = "false"
  storage_quota        = 10
  auto_sbom_generation = true
}

resource "harbor_robot_account" "rw-monofolio-rs" {
  name        = "rw-monofolio-rs"
  description = "Service account dedicated to r/w access to monofolio-rs project in Harbor"
  level       = "system"
  permissions {
    namespace = harbor_project.cache-dck.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
  permissions {
    namespace = harbor_project.cache-ghub.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
  permissions {
    namespace = harbor_project.cache-talos.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
  permissions {
    namespace = harbor_project.talos.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
  permissions {
    namespace = harbor_project.forgejo-action.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
  permissions {
    namespace = harbor_project.monofolio-rs.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
    access {
      action   = "push"
      resource = "repository"
    }
    access {
      action   = "read"
      resource = "repository"
    }
    access {
      action   = "delete"
      resource = "repository"
    }
    access {
      action   = "create"
      resource = "tag"
    }
    access {
      action   = "delete"
      resource = "tag"
    }
    access {
      action   = "read"
      resource = "sbom"
    }
    access {
      action   = "create"
      resource = "sbom"
    }
    access {
      action   = "read"
      resource = "artifact"
    }
    access {
      action   = "create"
      resource = "artifact"
    }
    access {
      action   = "list"
      resource = "artifact"
    }
  }
}

resource "vault_kv_secret_v2" "harbor_reader" {
  mount = "git-vault"
  name  = "batleforc/monofolio-rs/registry"
  data_json = jsonencode(
    {
      username = "${harbor_config_system.main.robot_name_prefix}${harbor_robot_account.rw-monofolio-rs.name}"
      password = harbor_robot_account.rw-monofolio-rs.secret
      url      = "https://registry.batleforc.fr"
    }
  )
}
