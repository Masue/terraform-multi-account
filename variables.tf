variable "main_access_key" {}
variable "main_secret_key" {}

variable "linked_access_key" {}
variable "linked_secret_key" {}

variable "region" {}

variable "source_ip" {
  description = " This ip-range will be used for our security groups"
  default = "94.143.188.0/29"
}

# We will be using Amazon Linux amis
variable "aws_amis" {
  default = {
    eu-central-1 = "ami-e2df388d"
    us-east-1 = "ami-08111162"
  }
}

variable "aws_nat_amis" {
  default = {
    eu-central-1 = "ami-0b322e67"
    us-east-1 = "ami-184dc970"
  }
}
