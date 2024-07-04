# Configure the AWS Provider
provider "aws" {
  region     = "eu-north-1"
}


# Create a VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp-vpc.id
  env_prefix = var.env_prefix
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  image_name = var.image_name
  instance_type = var.instance_type
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  avail_zone = var.avail_zone
  subnet_id = module.myapp-subnet.subnet.id
}