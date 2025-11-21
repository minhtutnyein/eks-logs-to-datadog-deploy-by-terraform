# VPC for EKS Cluster
module "vpc" {
  count   = var.create_eks_cluster ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = merge(
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      Environment                                 = "development"
      Terraform                                   = "true"
    },
    var.tags
  )
}

# EKS Cluster
module "eks" {
  count   = var.create_eks_cluster ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  vpc_id     = module.vpc[0].vpc_id
  subnet_ids = module.vpc[0].private_subnets

  # EKS Managed Node Group
  eks_managed_node_groups = {
    main = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "development"
        NodeGroup   = "main"
      }

      tags = merge(
        {
          Name = "${var.cluster_name}-node"
        },
        var.tags
      )
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  tags = merge(
    {
      Environment = "development"
      Terraform   = "true"
    },
    var.tags
  )
}

# Outputs for EKS cluster
output "cluster_id" {
  description = "EKS cluster ID"
  value       = var.create_eks_cluster ? module.eks[0].cluster_id : data.aws_eks_cluster.existing[0].id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = local.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = var.create_eks_cluster ? module.eks[0].cluster_security_group_id : "N/A - using existing cluster"
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = var.create_eks_cluster ? module.eks[0].cluster_oidc_issuer_url : "N/A - using existing cluster"
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name} --profile ${var.aws_profile}"
}
