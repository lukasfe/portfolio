# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "iac-portfolio"
}

# Set S3 bucket ACL
resource "aws_s3_bucket_acl" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  acl    = "private"
}

# Retrieve information about default VPC
data "aws_vpcs" "default" {}

# Create subnets in the default VPC
resource "aws_subnet" "private" {
  count = 3

  vpc_id           = data.aws_vpcs.default.ids[0]
  cidr_block       = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
}

# Create security group in the default VPC
resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster"
  description = "EKS Cluster Security Group"

  vpc_id = data.aws_vpcs.default.ids[0]

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
        "Service": "eks.amazonaws.com"
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
