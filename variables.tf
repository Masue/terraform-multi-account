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
    eu-west-1 = "ami-31328842"
    us-east-1 = "ami-08111162"
    us-west-1 = "ami-1b0f7d7b"
    us-west-2 = "ami-c229c0a2"
    ap-northeast-1 = "ami-f80e0596"
    ap-northeast-2 = "ami-6598510b"
    ap-southeast-1 = "ami-e90dc68a"
    ap-southeast-2 = "ami-f2210191"
    sa-east-1 = "ami-1e159872"
  }
}

variable "aws_nat_amis" {
  default = {
    eu-central-1 = "ami-0b322e67"
    eu-west-1 = "ami-14913f63"
    us-east-1 = "ami-184dc970"
    us-west-1 = "ami-0d087a6d"
    us-west-2 = "ami-030f4133"
    ap-northeast-1 = "ami-03cf3903"
    ap-northeast-2 = "ami-0199506f"
    ap-southeast-1 = "ami-1a9dac48"
    ap-southeast-2 = "ami-0154c73b"
    sa-east-1 = "ami-22169b4e"
  }
}
