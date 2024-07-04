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

variable avail_zone {}

variable env_prefix {}

variable "my_ip" {}

variable "instance_type" {}

variable "public_key_location" {}

variable "private_key_location" {}

# Create a VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}


#Create a subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
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

# Create an Intenet Gateway (IGW)
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

   tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# # Create Route Table (RTB)
# resource "aws_route_table" "myapp-route-table" {
#   vpc_id = aws_vpc.myapp-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }

#    tags = {
#     Name = "${var.env_prefix}-rtb"
#   }
# }

# # Associate the Internet Gateway to the Route Table (RTB)
# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id      = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-route-table.id
# }


# Associate the Internet Gateway to the default Route Table (RT)
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"  # default route
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

# # Create Security Group
# resource "aws_security_group" "myapp-sg" {
#   name = "myapp-sg"
#   vpc_id = aws_vpc.myapp-vpc.id

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.my_ip]
#   }
#   # ingress {
#   #   from_port = 80
#   #   to_port = 80
#   #   protocol = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }

#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     prefix_list_ids = []
#   }
#  tags = {
#     Name = "${var.env_prefix}-sg"
#   }
# }


# default Security Group
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
 tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

#Get latest instance from AWS
data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

#Get the ID of the instance
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}


#link your public key to aws to create 
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

# Create an EC2 Instance
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  # user_data = file("entry-script.sh")
  
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.private_key_location)
    # host = aws_instance.myapp-server.public_ip
    host = self.public_ip
  }

  provisioner "file" {
    source = "entry-script.sh"
    destination = "/home/ec2-user/entry-script-on-ec2.sh"
  }

  provisioner "remote-exec" {
    script = file("entry-script.sh")
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > public_ip.txt"    
  }

  tags = {
    Name = "${var.env_prefix}-server"
  }  
}

#Get the public IP  of the instance
output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}