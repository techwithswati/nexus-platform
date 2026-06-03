terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"  
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.27"  
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.13"  
    }
  }

  # Uncomment once you've created the S3 bucket manually first:
  # backend "s3" {}
  #   bucket         = "nexus-platform-tfstate-<your-account-id>"
  #   key            = "eks/terraform.tfstate"
  #   region         = "eu-west-2"
  #   dynamodb_table = "nexus-platform-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "nexus-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}