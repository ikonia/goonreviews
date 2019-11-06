# Specify the provider and access details
provider "aws" {
  access_key = "AKIAI7U4NGVS52MFVUHA"
  secret_key = "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"
  region     = "us-east-1"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "prod_cldblog" {
  cidr_block = "10.11.220.0/23"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  assign_generated_ipv6_cidr_block = false
  enable_classiclink = false

  tags {
    Name = "prod_cldblog_vpc"
    environment = "production"

  }
}
# set VPC AWS DHCP server options for host to take an address from
resource "aws_vpc_dhcp_options" "prod_cldblog_dhcp" {
  domain_name = "internal.providecloud.co.uk"
  domain_name_servers = ["${cidrhost(aws_vpc.prod_cldblog_vpc.cidr_block, 2)}"]
    tags {
      Name = "prod_cldblog_vpc"
    }
}

# define subnets for managmenet VPC 2 x public, 2 x private, spare address in middle
# Management public AZ1
resource "aws_subnet" "prod_cldblog_public_az1" {
  vpc_id = "${aws_vpc.prod_cldblog_vpc.id}"
  cidr_block = "10.11.220.0/27"
  availability_zone = "us-east-1a"
    tags {
      Name = "prod_cldblog_public_az1"
      AZ = "az1"
    }
}
# Management public AZ2
resource "aws_subnet" "prod_cldblog_public_az2" {
  vpc_id = "${aws_vpc.prod_cldblog_vpc.id}"
  cidr_block = "10.11.220.32/27"
  availability_zone = "us-east-1b"
    tags {
      Name = "prod_cldblog_public_az2"
      AZ = "az2"
    }
}

# Management private AZ1
resource "aws_subnet" "prod_cldblog_private_az1" {
  vpc_id = "${aws_vpc.prod_cldblog_vpc.id}"
  cidr_block = "10.11.220.64/26"
  availability_zone = "us-east-1a"
    tags {
      Name = "prod_cldblog_private_az1"
      AZ = "az1"
    }
}

# Management private AZ2
resource "aws_subnet" "prod_cldblog_private_az2" {
  vpc_id = "${aws_vpc.prod_cldblog_vpc.id}"
  cidr_block = "10.11.220.96/27"
  availability_zone = "us-east-1b"
    tags {
      Name = "prod_cldblog_private_az2"
      AZ = "az2"
    }
}

#put an internet gateway on the management VPC
resource "aws_internet_gateway" "prod_cldblog_igw" {
    vpc_id = "${prod_cldblog_vpc.management.id}"
      tags {
        Name = "prod_cldblog_igw"
      }
}

# setup the routes

resource "aws_route_table" "management_pub_route" {
    vpc_id = "${aws_vpc.management.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.management_igw.id}"
    }

    tags {
        Name = "management_pub_route"
    }
}

resource "aws_route_table" "management_pri_route" {
    vpc_id = "${aws_vpc.management.id}"

    tags {
        Name = "management_pri_route"
    }
}




#resource "aws_route_table_association" "management_pub_route" {
#    subnet_id = "${aws_subnet.management_public_az1.id : aws_subnet.management_public_az2.id}"
#    route_table_id = "${aws_route_table.management_pub_route.id}"
#}
