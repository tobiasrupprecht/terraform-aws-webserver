terraform {
  backend "remote" {
    organization = "hashicorp-tobiasrupprecht"
    workspaces {
      name = "AWS-remote-state"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

module "webserver-eu-west-1" {
  source            = "./modules/Webserver"
  region            = "eu-west-1"
  availability_zone = "eu-west-1b"
  instance_type     = "t2.micro"
  #Packer build AMI:
  ami               = "ami-01cacdc91c4e00085"
  env               = "${var.env}"
}

module "webserver-eu-north-1" {
  source            = "./modules/Webserver"
  region            = "eu-north-1"
  availability_zone = "eu-north-1b"
  instance_type     = "t3.micro"
  #Packer build AMI:
  ami               = "ami-0653bfa32be002aa9"
  env               = "${var.env}"
}