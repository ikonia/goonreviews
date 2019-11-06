# Main variables
variable "aws_access_key" {
     description = "Access key to AWS"
 }
variable "aws_secret_key" {
     description = "Secret key to AWS"
 }
variable "aws_region" {
     description = "Region of AWS VPC"
 }
variable "availability_zone" {
     description = "availability zones used for vpcs"
     default = {
       us-east-1 = "us-east-1a"
       us-east-2 = "us-east-2a"
     }
}


# components for VPC to be created

variable "vpc_name" {
    description = "name of VPC"
}

variable "vpc_region" {
    description = "region to host vpc"
}

variable "vpc_public_subnet_1_cidr" {
    description = "pubic subnet cidr for az1"
}

variable "vpc_private_subnet_1_cidr" {
    description = "private subnet cidr for az1"
}

