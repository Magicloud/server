terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "3.12.0"
    }
  }
}

provider "minio" {
  minio_server   = "minio.magicloud.lan:443"
  minio_user     = "minio"
  minio_password = "minio123"
  minio_ssl      = true
}

provider "kubernetes" {
  config_path = "/etc/rancher/k3s/k3s.yaml"
  config_context = "default"
}

module "alertmanager_bucket" {
    source = "./buckets"
    username = "alertmanager-mimir"
    buckets = ["alertmanager-mimir"]
    k8s_secret_namespace = "monitoring"
}
module "mimir_bucket" {
    source = "./buckets"
    username = "mimir"
    buckets = ["mimir"]
    k8s_secret_namespace = "monitoring"
}
module "ruler_bucket" {
    source = "./buckets"
    username = "ruler-mimir"
    buckets = ["ruler-mimir"]
    k8s_secret_namespace = "monitoring"
}

module "loki0_buckets" {
  source = "./buckets"
  username = "loki0"
  buckets = ["chunks-loki", "ruler-loki", "admin-loki"]
  k8s_secret_namespace = "monitoring"
}