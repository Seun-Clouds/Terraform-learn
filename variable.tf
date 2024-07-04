variable "vpc_cidr_block" {
    description = "VPC cidr block"
    type = string
}

variable "subnet_cidr_block" {
    description = "Subnet cidr block"
    type = string
}

variable avail_zone {}

variable env_prefix {}

variable "my_ip" {}

variable "instance_type" {}

variable "public_key_location" {}

variable "image_name" {}
