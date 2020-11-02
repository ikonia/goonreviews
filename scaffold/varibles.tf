# Main variables
# commented while working with local access file
#variable "aws_access_key" {
#     description = "Access key to AWS"
# }

# commented while working with local acess file
#variable "aws_secret_key" {
#     description = "Secret key to AWS"
# }


###################
# work starts here
###################

variable "aws_region" {
 description = "Region of AWS VPC"
 default     = "us-east-1"
 }

variable "vpc_name" {
  description = "name of VPC"
}

variable "vpc_top_cidr" {
  description = "top level IP range for the VPC"
  default     = ("10.11.218.0/23")
}













#######################################
# sort this stuff out - do the IP maths
#######################################
#variable "vpc_public_subnet_1_cidr" {
#    description = "pubic subnet cidr for az1"
#}
#
#variable "vpc_private_subnet_1_cidr" {
#    description = "private subnet cidr for az1"
#}

variable "hosting_environment" {
  description = "name of hosting environment, prod/non-prod/test/etc"
  default     = ("production")
}
