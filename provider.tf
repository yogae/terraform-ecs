provider "aws" {
  region  = "ap-northeast-2"
  version = "~> 2.7"
  profile = "jihyun"
  allowed_account_ids = "${var.allowed_account_ids}"
  forbidden_account_ids = "${var.forbidden_account_ids}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

terraform {
  required_version = ">= 0.12.0"
}