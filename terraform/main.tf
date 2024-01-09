provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "iac-portfolio"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "portfolio"
  subnets           = ["subnet-1", "subnet-2", "subnet-3"]
  node_groups       = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
    }
  }
}
#
