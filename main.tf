terraform {
  required_version = ">=1.10.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.7.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "v2.20.2"

  hcloud_token              = var.hcloud_token
  cluster_name              = var.cluster_name
  cluster_prefix            = true
  datacenter_name           = "ash-dc1"
  firewall_use_current_ip   = false
  firewall_kube_api_source  = ["0.0.0.0/0"]
  firewall_talos_api_source = ["0.0.0.0/0"]
  talos_version             = "v1.11.5"
  control_plane_count       = 3
  control_plane_server_type = "cpx21"
  worker_nodes = [
    {
      type = "cpx51"
    }
  ]
  # arm does not exist on US datacenters yet
  disable_arm        = true
  kubernetes_version = "1.34.2"
}

resource "local_file" "talosconfig" {
  filename = "./config/talosconfig"
  content  = module.talos.talosconfig
}

resource "local_file" "kubeconfig" {
  filename = "./config/kubeconfig"
  content  = module.talos.kubeconfig
}

provider "kubernetes" {
  config_path = "./config/kubeconfig"
}

resource "kubernetes_namespace" "flux-system" {
  metadata {
    name = "flux-system"
  }
  depends_on = [local_file.kubeconfig]
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_secret" "sops-age" {
  metadata {
    name      = "sops-age"
    namespace = "flux-system"
  }
  data = {
    "age.agekey" = file("${path.root}/config/key.txt")
  }
  depends_on = [kubernetes_namespace.flux-system]
}

provider "flux" {
  kubernetes = {
    config_path = "./config/kubeconfig"
  }
  git = {
    url          = var.flux_git_repo_url
    author_email = var.flux_author_email
    http = {
      username = "git"
      password = var.github_token
    }
  }
}

resource "flux_bootstrap_git" "flux" {
  depends_on         = [kubernetes_secret.sops-age]
  embedded_manifests = true
  components_extra = [
    "image-reflector-controller",
    "image-automation-controller"
  ]
  kustomization_override = file("${path.root}/config/flux-kustomization-patch.yaml")
  path                   = "clusters/production"
}
