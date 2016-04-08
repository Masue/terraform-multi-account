# Specify the provider and access details
provider "aws" {
  region = "${var.region}"
  access_key = "${var.linked_access_key}"
  secret_key = "${var.linked_secret_key}"
  alias = "link"
}


########
## VPC
########
# Create a VPC to launch our instances into
resource "aws_vpc" "blogpost_linked_vpc" {
  provider = "aws.link"
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "blog"
  }
}

resource "aws_subnet" "blogpost_linked_public_subnet" {
  provider = "aws.link"
  vpc_id                  = "${aws_vpc.blogpost_linked_vpc.id}"
  cidr_block              = "${aws_vpc.blogpost_linked_vpc.cidr_block}"
  map_public_ip_on_launch = true
}

###########
## EC2
###########
resource "aws_instance" "blogpost_linked_instance1" {
  provider = "aws.link"
  connection {
    user = "ec2-user"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_nat_amis, var.region)}"
  vpc_security_group_ids = ["${aws_security_group.blogpost_link_sg.id}"]
  subnet_id = "${aws_subnet.blogpost_linked_public_subnet.id}"
  tags {
      Name = "Blog link instance 1"
  }
}

########
## SG
########
resource "aws_security_group" "blogpost_link_sg" {
  provider = "aws.link"
  name        = "blogpost_link_sg"
  vpc_id      = "${aws_vpc.blogpost_linked_vpc.id}"
# HTTP access from main account
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.blogpost_nat_eip.public_ip}/32"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.blogpost_nat_eip.public_ip}/32"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
