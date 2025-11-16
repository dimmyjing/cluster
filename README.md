# Cluster

Most of this repository uses [terraform-hcloud-talos](https://github.com/hcloud-talos/terraform-hcloud-talos)

## Initialization process

1. Create `config/key.txt` file as an `age` key file
2. Edit `config/env.yaml` to fill in all the required api keys
3. Run `mise packer`
4. Run `mise tofu:init`
5. Run `mise tofu:apply`
