# main.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.infrastructure.cluster_endpoint
  cluster_ca_certificate = base64decode(module.infrastructure.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster" "eks" {
  name = module.infrastructure.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.infrastructure.cluster_name
}

module "k8s" {
  source = "./modules/k8s"

  db_username = var.db_username
  db_password = var.db_password
}

module "infrastructure" {
  source = "./infrastructure"
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = module.infrastructure.jenkins_public_ip
}

output "grafana_public_ip" {
  description = "Public IP of Grafana server"
  value       = module.infrastructure.grafana_public_ip
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.infrastructure.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.infrastructure.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS Cluster CA"
  value       = module.infrastructure.cluster_ca_certificate
}

output "jenkins_initial_password_command" {
  description = "Command to get Jenkins initial admin password"
  value       = "sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
}

output "eks_cluster_id" {
  value       = aws_eks_cluster.eks.id
  description = "ID of the EKS Cluster"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "EKS Cluster endpoint"
}
