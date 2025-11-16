# Cluster

Most of this repository uses [terraform-hcloud-talos](https://github.com/hcloud-talos/terraform-hcloud-talos)

## Initialization process

1. Retrieve Hetzner API token and put it in `/config/env.yaml`
2. Run `mise packer`
3. Run `tofu init`
4. Run `tofu apply`
