terraform {
  backend "s3" {
    bucket         = "shopcloud-tfstate-khalil-karim"
    key            = "shopcloud/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shopcloud-tf-locks"
    encrypt        = true
  }
}