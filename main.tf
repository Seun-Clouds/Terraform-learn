# Configure the AWS Provider
provider "aws" {
  region     = "eu-north-1"
}
 
variable "subnet_cidr_block" {
    description = "Subnet cidr block"
    type = string
}

variable "vpc_cidr_block" {
    description = "VPC cidr block"
    type = string
}

variable "environment" {
  description = "Deployment environment"
}

# Create a VPC
resource "aws_vpc" "mydev-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = var.environment
  }
}

#Create a subnet
resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.mydev-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "eu-north-1a"

  tags = {
    Name = "Dev subnet 1"
  }
}

# #add subnet to exising vpn
# data "aws_vpc" "exising_vpc" {
#   default = true
# }

# #Create a subnet
# resource "aws_subnet" "dev-subnet-2" {
#   vpc_id     = data.aws_vpc.exising_vpc.id
#   cidr_block = "172.31.48.0/20"
#   availability_zone = "eu-north-1a"

#   tags = {
#     Name = "Def Dev subnet 2"
#   }
# }

# output "dev-vpc-id" {
#   value = aws_vpc.mydev-vpc.id
# }

# output "dev-subnet-id" {
#   value = aws_subnet.dev-subnet-1.id
# }