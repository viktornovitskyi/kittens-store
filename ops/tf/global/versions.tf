terraform {
  # pin terraform version
  required_version = "1.0.3"

  # required providers for our bootcamp with version pinning
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.51"
    }
  }

  backend "s3" {
    bucket = "devops-bootcamp"
    key    = "global/state.tfstate"
    region = "eu-central-1"
  }
}