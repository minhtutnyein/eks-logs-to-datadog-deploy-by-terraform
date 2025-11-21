provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Cluster endpoint and auth for providers
locals {
  cluster_endpoint   = var.create_eks_cluster ? module.eks[0].cluster_endpoint : data.aws_eks_cluster.existing[0].endpoint
  cluster_ca_cert    = var.create_eks_cluster ? base64decode(module.eks[0].cluster_certificate_authority_data) : base64decode(data.aws_eks_cluster.existing[0].certificate_authority[0].data)
  cluster_name_final = var.cluster_name
}

data "aws_eks_cluster" "existing" {
  count = var.create_eks_cluster ? 0 : 1
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name_final
}

# Provider configurations for Kubernetes and Helm
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_cert
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_cert
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
