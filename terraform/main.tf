# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "iac-portfolio"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Create VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create subnets in the new VPC
resource "aws_subnet" "private" {
  count = 3

  vpc_id           = aws_vpc.portfolio_vpc.id
  cidr_block       = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
}

# Create security group in the new VPC
resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster"
  description = "EKS Cluster Security Group"

  vpc_id = aws_vpc.portfolio_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["eks.amazonaws.com", "ec2.amazonaws.com"]
      }
    }
  ]
}
EOF
}

# Create EKS cluster
resource "aws_eks_cluster" "portfolio_cluster" {
  name     = "portfolio-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
}

# Create EKS node group
resource "aws_eks_node_group" "portfolio_nodes" {
  cluster_name    = aws_eks_cluster.portfolio_cluster.name
  node_group_name = "portfolio-nodes"

  subnet_ids      = aws_subnet.private[*].id
  node_role_arn   = aws_iam_role.eks_cluster.arn

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = "portfolio-key"
  }
}