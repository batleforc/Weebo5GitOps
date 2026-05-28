resource "harbor_project" "batleforc" {
  name                 = "batleforc"
  public               = "false"
  storage_quota        = 20
  auto_sbom_generation = true
}

resource "harbor_retention_policy" "main" {
  scope    = harbor_project.batleforc.id
  schedule = "Daily"
  rule {
    repo_matching        = "batleforc/monofolio-rs"
    tag_matching         = "**"
    always_retain        = true
    most_recently_pushed = 2
  }
  rule {
    most_recently_pushed = 2
    repo_matching        = "batleforc/monofolio-rs/cache"
    tag_matching         = "**"
    always_retain        = true
  }
}

resource "harbor_robot_account" "rw-batleforc" {
  name        = "rw-batleforc"
  description = "Service account dedicated to r/w access to batleforc project in Harbor"
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
    namespace = harbor_project.batleforc.name
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

resource "harbor_robot_account" "r-batleforc" {
  name        = "r-batleforc"
  description = "Service account dedicated to read only access to batleforc project in Harbor"
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
    namespace = harbor_project.batleforc.name
    kind      = "project"
    access {
      action   = "pull"
      resource = "repository"
    }
  }
}

resource "vault_kv_secret_v2" "rw-monofolio-rs" {
  mount = "git-vault"
  name  = "batleforc/monofolio-rs/registry"
  data_json = jsonencode(
    {
      username = "${harbor_config_system.main.robot_name_prefix}${harbor_robot_account.rw-batleforc.name}"
      password = harbor_robot_account.rw-batleforc.secret
      url      = "registry.batleforc.fr"
    }
  )
}

resource "vault_kv_secret_v2" "rw-batleforc" {
  mount = "mv"
  name  = "dev-ws-max/registry"
  data_json = jsonencode(
    {
      username = "${harbor_config_system.main.robot_name_prefix}${harbor_robot_account.rw-batleforc.name}"
      password = harbor_robot_account.rw-batleforc.secret
      url      = "registry.batleforc.fr"
    }
  )
}

resource "vault_kv_secret_v2" "r-monofolio-rs" {
  mount = "mv"
  name  = "monofolio/registry"
  data_json = jsonencode(
    {
      username = "${harbor_config_system.main.robot_name_prefix}${harbor_robot_account.r-batleforc.name}"
      password = harbor_robot_account.r-batleforc.secret
      url      = "https://registry.batleforc.fr"
    }
  )
}


resource "vault_kv_secret_v2" "rw-batlehub-rs" {
  mount = "git-vault"
  name  = "batleforc/batlehub/registry"
  data_json = jsonencode(
    {
      username = "${harbor_config_system.main.robot_name_prefix}${harbor_robot_account.rw-batleforc.name}"
      password = harbor_robot_account.rw-batleforc.secret
      url      = "registry.batleforc.fr"
    }
  )
}
