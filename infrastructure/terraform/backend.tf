terraform {
  backend "s3" {
    bucket         = "neupokoevcv-terraform-state-902225599141-eu-central-1"
    key            = "neupokoevcv/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "neupokoevcv-terraform-locks"
    encrypt        = true
  }
}
