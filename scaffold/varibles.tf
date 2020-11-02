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

# no longer needed - in module as params - totally delete once testing removed
#variable "availability_zone" {
#     description = "availability zones used for vpcs"
#     default = {
#       us-east-1 = "us-east-1a"
#       us-east-2 = "us-east-2a"
#     }
#}


# components for VPC to be created

variable "vpc_name" {
    description = "name of VPC"
}

variable "vpc_region" {
    description = "region to host vpc"
}

variable "vpc_top_cidr" {
    description = "top level IP range for the VPC"
		default = ( "10.11.218.0/23" )
}
#variable "vpc_public_subnet_1_cidr" {
#    description = "pubic subnet cidr for az1"
#}
#
#variable "vpc_private_subnet_1_cidr" {
#    description = "private subnet cidr for az1"
#}

variable "hosting_environment" {
    description = "name of hosting environment, prod/non-prod/test/etc"
		default = ( "production" )
}

