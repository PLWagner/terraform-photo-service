terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "kubernetes" {
  alias                  = "backend"
  cluster_ca_certificate = var.k8s_provider_cluster_ca_certificate
  host                   = var.k8s_provider_chost
  token                  = var.k8s_provider_ctoken
}

provider "kubernetes" {
  alias                  = "frontend"
  cluster_ca_certificate = var.k8s_provider_cluster_ca_certificate_public
  host                   = var.k8s_provider_chost_public
  token                  = var.k8s_provider_ctoken_public
}
