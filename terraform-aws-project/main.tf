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
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

module "k8s" {
  source = "./modules/k8s"

  db_password = var.db_password
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "grafana_public_ip" {
  description = "Public IP of Grafana server"
  value       = aws_instance.grafana.public_ip
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
