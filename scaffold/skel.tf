terraform {
  required_providers {
    aws = {
      source   = "hashicorp/aws"
      vversion = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # commented while testing using local key file
  #access_key              = var.aws_access_key
  #secret_key              = var.aws_secret_key
  shared_credentials_file = "~/.aws/credentials"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "generic_vpc" {
  cidr_block                       = var.vpc_top_cidr
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false
  enable_classiclink               = false

  tags = {
    Name        = var.vpc_name
    environment = var.hosting_environment
  }
}

# set VPC AWS DHCP server options for host to take an address from
resource "aws_vpc_dhcp_options" "generic_vpc_dhcp" {
  domain_name         = "${var.hosting_environment}.aws.no-dns.co.uk"
  domain_name_servers = [cidrhost(aws_vpc.generic_vpc.cidr_block, 2)]
  tags = {
    Name        = "${var.vpc_name}_dhcp_options"
    environment = var.hosting_environment
  }
}


# define subnets for workload VPC 2 x public, 2 x private, spare address in middle workload public az1

resource "aws_subnet" "generic_vpc_public_subnet_az1" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.0/26"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${var.vpc_name}_public_subnet_az1"
    environment = var.hosting_environment
    az          = "az1"
    seczone     = "red"
  }
}

# workload public az2
resource "aws_subnet" "generic_vpc_public_subnet_az2" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.64/26"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name        = "${var.vpc_name}_public_subnet_az2"
    environment = var.hosting_environment
    az          = "az2"
    seczone     = "red"
  }
}

# workload private az1
resource "aws_subnet" "generic_vpc_private_subnet_az1" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.128/26"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${var.vpc_name}_private_subnet_az1"
    environment = var.hosting_environment
    az          = "az1"
    seczone     = "amber"
  }
}

# workload private az2
resource "aws_subnet" "generic_vpc_private_subnet_az2" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.192/26"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name        = "${var.vpc_name}_private_subnet_az2"
    environment = var.hosting_environment
    az          = "az2"
    seczone     = "amber"
  }
}

# workload data az1
resource "aws_subnet" "generic_vpc_data_subnet_az1" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.128/26"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${var.vpc_name}_data_subnet_az1"
    environment = var.hosting_environment
    az          = "az1"
    seczone     = "green"
  }
}


# workload data az2
resource "aws_subnet" "generic_vpc_data_subnet_az2" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.128/26"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name        = "${var.vpc_name}_data_subnet_az2"
    environment = var.hosting_environment
    az          = "az2"
    seczone     = "green"
   }
}

# workload management az1
resource "aws_subnet" "generic_vpc_mgt_subnet_az1" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.128/26"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name        = "${var.vpc_name}_mgt_subnet_az1"
    environment = var.hosting_environment
    az          = "az1"
    seczone     = "blue"
  }
}

# workload management az2
resource "aws_subnet" "generic_vpc_mgt_subnet_az2" {
  vpc_id            = aws_vpc.generic_vpc.id
  cidr_block        = "10.11.218.128/26"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name        = "${var.vpc_name}_mgta_subnet_az2"
    environment = var.hosting_environment
    az          = "az2"
    seczone     = "blue"
  }
}


#put an internet gateway on the workload VPC
resource "aws_internet_gateway" "generic_vpc_igw" {
  vpc_id = aws_vpc.generic_vpc.id
  tags = {
    Name        = "${var.vpc_name}_igw"
    environment = var.hosting_environment
  }
}

# setup the routes

resource "aws_route_table" "generic_vpc_default_pub_route" {
  vpc_id = aws_vpc.generic_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.generic_vpc_igw.id
  }
  tags = {
    Name        = "${var.vpc_name}_pub_route_table"
    environment = var.hosting_environment
  }
}

resource "aws_route_table" "generic_vpc_default_pri_route" {
  vpc_id = aws_vpc.generic_vpc.id
  tags = {
    Name        = "${var.vpc_name}_pri_route_table"
    environment = var.hosting_environment
  }
}


# basic route attachement
resource "aws_route_table_association" "generic_vpc_associate_pub_route" {
  #subnet_id = "${aws_subnet.generic_vpc_public_subnet_az1.id} : ${aws_subnet.generic_vpc_public_subnet_az2.id}"
  subnet_id      = aws_subnet.generic_vpc_public_subnet_az1.id
  route_table_id = aws_route_table.generic_vpc_default_pub_route.id
}

resource "aws_route_table_association" "generic_vpc_associate_pri_route" {
  #subnet_id = "${aws_subnet.generic_vpc_public_subnet_az1.id} : ${aws_subnet.generic_vpc_public_subnet_az2.id}"
  subnet_id      = aws_subnet.generic_vpc_private_subnet_az1.id
  route_table_id = aws_route_table.generic_vpc_default_pri_route.id
}
