provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "static_website" {
  bucket = "iac-portfolio"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
#
