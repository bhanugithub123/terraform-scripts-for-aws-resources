terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region = "us-east-2"
  access_key = "enter your access key"
  secret_key = "enter your secret key"
}