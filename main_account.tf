# Specify the provider and access details
provider "aws" {
  region = "${var.region}"
  access_key = "${var.main_access_key}"
  secret_key = "${var.main_secret_key}"
}


########
## VPC
########
# Create a VPC to launch our instances into
resource "aws_vpc" "blogpost_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "blog"
  }
}

resource "aws_subnet" "blogpost_public_subnet" {
  vpc_id                  = "${aws_vpc.blogpost_vpc.id}"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "blogpost_main_private_subnet1" {
  vpc_id                  = "${aws_vpc.blogpost_vpc.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "blogpost_main_private_subnet2" {
  vpc_id                  = "${aws_vpc.blogpost_vpc.id}"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = false
}

#######
## IGW
#######
resource "aws_internet_gateway" "blogpost_igw" {
  vpc_id = "${aws_vpc.blogpost_vpc.id}"
  tags {
    Name = "blog-igw"
  }
}

############
## ROUTES
#############
#public route for public subnet
resource "aws_route_table" "blog_public_route" {
  vpc_id = "${aws_vpc.blogpost_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.blogpost_igw.id}"
  }
  tags {
    Name = "pub route nat"
  }
}

# route to NAT instance for private subnets
resource "aws_route_table" "blog_private_route" {
  vpc_id = "${aws_vpc.blogpost_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.blogpost_nat.id}"
  }
  tags {
    Name = "pub route private subnet"
  }
}

######################
## ROUTE ASSOCIATIONS
#######################
## associate blog_public_route with the public subnet
resource "aws_route_table_association" "blogpost_assoc_pub" {
    subnet_id = "${aws_subnet.blogpost_public_subnet.id}"
    route_table_id = "${aws_route_table.blog_public_route.id}"
}

## associate blog_public_route with the public subnet
resource "aws_route_table_association" "blogpost_assoc_priv1" {
    subnet_id = "${aws_subnet.blogpost_main_private_subnet1.id}"
    route_table_id = "${aws_route_table.blog_private_route.id}"
}
resource "aws_route_table_association" "blogpost_assoc_priv2" {
    subnet_id = "${aws_subnet.blogpost_main_private_subnet2.id}"
    route_table_id = "${aws_route_table.blog_private_route.id}"
}

########
## EIP
########
resource "aws_eip" "blogpost_nat_eip" {
  instance = "${aws_instance.blogpost_nat.id}"
  vpc = true
}


#########
## EC2
#########

resource "aws_instance" "blogpost_nat" {
  connection {
    user = "ec2-user"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_nat_amis, var.region)}"
  vpc_security_group_ids = ["${aws_security_group.blogpost_nat_sg.id}"]
  subnet_id = "${aws_subnet.blogpost_public_subnet.id}"
  source_dest_check = false
  tags {
      Name = "NAT"
  }
}

resource "aws_instance" "blogpost_app_instance1" {
  connection {
    user = "ec2-user"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_nat_amis, var.region)}"
  vpc_security_group_ids = ["${aws_security_group.blogpost_app_sg.id}"]
  subnet_id = "${aws_subnet.blogpost_main_private_subnet1.id}"
  tags {
      Name = "APP1"
  }
}

resource "aws_instance" "blogpost_app_instance2" {
  connection {
    user = "ec2-user"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.region)}"
  vpc_security_group_ids = ["${aws_security_group.blogpost_app_sg.id}"]
  subnet_id = "${aws_subnet.blogpost_main_private_subnet2.id}"
  tags {
      Name = "APP2"
  }
}

#########
## SG
########

resource "aws_security_group" "blogpost_nat_sg" {
  name        = "blogpost_nat_sg"
  vpc_id      = "${aws_vpc.blogpost_vpc.id}"
# HTTP access from private subnet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.blogpost_main_private_subnet1.cidr_block}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.blogpost_main_private_subnet1.cidr_block}"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.blogpost_main_private_subnet1.cidr_block}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.blogpost_main_private_subnet2.cidr_block}"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "blogpost_app_sg" {
  name        = "blogpost_app_sg"
  vpc_id      = "${aws_vpc.blogpost_vpc.id}"
# HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.blogpost_nat_sg.id}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
