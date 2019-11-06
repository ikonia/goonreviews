# Create a VPC to launch our instances into
resource "aws_vpc" "prd_hosting_01" {
  cidr_block = "10.11.218.0/23"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  assign_generated_ipv6_cidr_block = false
  enable_classiclink = false

  tags {
    Name = "hosting_vpc"
    environment = "production"


  }
}
# set VPC AWS DHCP server options for host to take an address from
resource "aws_vpc_dhcp_options" "prd_hosting_01_dhcp" {
  domain_name = "aws.no-dns.co.uk"
  domain_name_servers = ["${cidrhost(aws_vpc.prd_hosting_01.cidr_block, 2)}"]
    tags {
      Name = "hosting_vpc_dhcp"
      environment = "production"
    }
}

# define subnets for managmenet VPC 2 x public, 2 x private, spare address in middle
# Management public AZ1
resource "aws_subnet" "prd_hosting_01_public_az1" {
  vpc_id = "${aws_vpc.prd_hosting_01.id}"
  cidr_block = "10.11.218.0/26"
  availability_zone = "us-east-1a"
    tags {
      Name = "prd_hosting_01_public_az1"
      AZ = "az1"
    }
}
# Management public AZ2
resource "aws_subnet" "prd_hosting_02_public_az2" {
  vpc_id = "${aws_vpc.prd_hosting_01.id}"
  cidr_block = "10.11.218.64/26"
  availability_zone = "us-east-1b"
    tags {
      Name = "prd_hosting_01_public_az2"
      AZ = "az2"
    }
}

# Management private AZ1
resource "aws_subnet" "prd_hosting_01_private_az1" {
  vpc_id = "${aws_vpc.prd_hosting_01.id}"
  cidr_block = "10.11.218.128/26"
  availability_zone = "us-east-1a"
    tags {
      Name = "prd_hosting_01_private_az1"
      AZ = "az1"
    }
}

# Management private AZ2
resource "aws_subnet" "prd_hosting_01_private_az2" {
  vpc_id = "${aws_vpc.prd_hosting_01.id}"
  cidr_block = "10.11.218.192/26"
  availability_zone = "us-east-1b"
    tags {
      Name = "prd_hosting_01_private_az2"
      AZ = "az2"
    }
}

#put an internet gateway on the management VPC
resource "aws_internet_gateway" "prod_hosting_01_igw" {
    vpc_id = "${aws_vpc.prd_hosting_01.id}"
      tags {
        Name = "prod_hosting_01_igw"
        environment = "production"
      }
}

# setup the routes

resource "aws_route_table" "prd_hosting_01_pub_route" {
    vpc_id = "${aws_vpc.prod_hosting_01.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.prd_hosting_01_igw.id}"
    }

    tags {
        Name = "prod_hosting_01_pub_route"
        environment = "production"
    }
}

resource "aws_route_table" "prd_hosting_01_pri_route" {
    vpc_id = "${aws_vpc.prd_hosting_01.id}"

    tags {
        Name = "management_pri_route"
        environment = "production"
    }
}




#resource "aws_route_table_association" "prd_hosting_01_pub_route" {
#    subnet_id = "${aws_subnet.prd_hosting_01_public_az1.id : aws_subnet.prod_hosting_01_public_az2.id}"
#    route_table_id = "${aws_route_table.prd_hosting_01_pub_route.id}"
#}

