variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "jimmy-cluster"
}

variable "flux_git_repo_url" {
  description = "Git repository URL for FluxCD"
  type        = string
  default     = "https://github.com/dimmyjing/cluster"
}

variable "flux_author_email" {
  description = "Author email for FluxCD Git commits"
  type        = string
  default     = "jimmyguding@gmail.com"
}

variable "github_token" {
  description = "GitHub Token for accessing private repositories"
  type        = string
}

variable "state_passphrase" {
  description = "Passphrase for encrypting the Terraform state"
  type        = string
}
