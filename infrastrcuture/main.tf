data "digitalocean_kubernetes_versions" "doks" {}

resource "digital_ocean_kubernetes_cluster" "demo" {
  name    = "training-demo"
  region  = "fra1"
  version = data.digitalocean_kubernetes_versions.doks.latest_version

  node_pool {
    name       = "default"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}

# TODO: Add Helm release for ingress-nginx
# TODO: Add Helm release for cert-manager
# TODO: Add Helm release for external-dns
# TODO: Add Helm release for prometheus-operator
# TODO: Add Helm release for kube-prometheus-stack
