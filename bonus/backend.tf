terraform {
  backend "s3" {
    bucket  = "gh-actions-wordpress-tfstate-068648884177"
    key     = "wordpress-rds/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
