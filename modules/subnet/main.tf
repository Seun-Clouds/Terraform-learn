
#Create a subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# Create an Intenet Gateway (IGW)
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id

   tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# Associate the Internet Gateway to the default Route Table (RT)
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"  # default route
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}
