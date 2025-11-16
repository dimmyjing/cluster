terraform {
  required_version = ">=1.10.0"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.5.0"
    }
  }
}

data "http" "personal_ipv4" {
  count = 1
  url   = "https://ipv4.icanhazip.com"
}

module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "v2.20.2"

  hcloud_token              = var.hcloud_token
  cluster_name              = "jimmy-cluster"
  cluster_prefix            = true
  datacenter_name           = "ash-dc1"
  firewall_use_current_ip   = false
  firewall_kube_api_source  = ["${chomp(data.http.personal_ipv4[0].response_body)}/32"]
  firewall_talos_api_source = ["${chomp(data.http.personal_ipv4[0].response_body)}/32"]
  talos_version             = "v1.11.5"
  control_plane_count       = 3
  control_plane_server_type = "cpx11"
  worker_nodes = [
    {
      type = "cpx51"
    }
  ]
  # arm does not exist on US datacenters yet
  disable_arm = true
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}
