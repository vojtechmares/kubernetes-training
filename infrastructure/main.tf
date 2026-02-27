locals {
  kubernetes_minor_version = "1.28"
}

data "cloudflare_zone" "demo" {
  name = "maresdemo.com"
}

data "digitalocean_kubernetes_versions" "doks" {}

resource "digitalocean_kubernetes_cluster" "demo" {
  name    = "training-demo-k8s"
  region  = "fra1"
  version = [for version in data.digitalocean_kubernetes_versions.doks.versions : version.version if startswith(version, local.kubernetes_minor_version)][0]

  node_pool {
    name       = "default"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.demo.kube_config[0].raw_config
  sensitive = true
}

resource "digitalocean_loadbalancer" "demo" {
  name   = "training-demo-lb"
  region = "fra1"

  droplet_tag = "k8s:${digitalocean_kubernetes_cluster.demo.id}"

  healthcheck {
    port     = 32080
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 80
    target_port     = 32080
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 443
    target_port     = 32443
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  depends_on = [
    digitalocean_kubernetes_cluster.demo,
  ]
}

resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.demo.zone_id
  name    = "*.k8s"
  value   = digitalocean_loadbalancer.demo.ip
  type    = "A"
  ttl     = 300
  proxied = false
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.1"
  create_namespace = true

  atomic  = true
  timeout = 900

  values = [
    file("./helm-values/ingress-nginx.yaml")
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.demo
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.19.3"
  namespace        = "cert-manager"
  create_namespace = true

  atomic  = true
  timeout = 900

  values = [
    file("./helm-values/cert-manager.yaml"),
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.demo,
  ]
}

resource "time_sleep" "wait_for_crds" {
  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx,
  ]

  create_duration = "30s"
}

resource "kubectl_manifest" "clusterissuer_letsencrypt_prod" {
  depends_on = [
    time_sleep.wait_for_crds,
  ]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: nobody@maresdemo.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
YAML
}

resource "kubectl_manifest" "clusterissuer_letsencrypt_staging" {
  depends_on = [
    time_sleep.wait_for_crds,
  ]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: nobody@maresdemo.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
YAML
}

resource "helm_release" "kube_promehtheus_stack" {
  name             = "monitoring"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.5.0"
  create_namespace = true

  atomic  = true
  timeout = 900

  values = [
    file("./helm-values/kube-prometheus-stack.yaml"),
  ]

  depends_on = [
    digitalocean_kubernetes_cluster.demo,
  ]
}
