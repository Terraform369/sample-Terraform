#####################################################################################################
# 	AWS - Infrastructure Module - Creates VPC, IGW, Subnet, Route tables, Associations etc      	#
#	Author: Janaki			Version 0:	2nd May 2020								                #
#							Version 1:	Split code into modules	3rd May 2020		                #
#####################################################################################################
module "shared_vars" {
  source = "../shared_vars"
}

locals {
	env 			= "${terraform.workspace}"

    vpcid_env = {
        default = aws_vpc.myvpc.id
		production 	= "vpc-b050a4d9"
	}
	vpcid 			= "${lookup(local.vpcid_env, local.env)}"

    publicsubnetid1_env = {
		default 	= aws_subnet.mysubnet-1.id
		production 	= "subnet-4268942b"
	}
	publicsubnetid1 = "${lookup(local.publicsubnetid1_env, local.env)}"

	publicsubnetid2_env = {
		default 	= aws_subnet.mysubnet-2.id
		production 	= "subnet-d65d699c"
	}
	publicsubnetid2 = "${lookup(local.publicsubnetid2_env, local.env)}"

	privatesubnetid_env = {
		default 	= aws_subnet.mysubnet-3.id
		production 	= "subnet-9c9387e4"
	}
	privatesubnetid = "${lookup(local.privatesubnetid_env, local.env)}"
}

provider "aws" {
  region                  = "${module.shared_vars.regionname}"
}

######
# VPC
######
# VPC creation with 3 subnets
resource "aws_vpc" "myvpc" {
  cidr_block              = "${module.shared_vars.cidr_vpc_id}"
  enable_dns_hostnames    = true

  tags = {
    Name                  = "myvpc-${module.shared_vars.env_suffix}"
  }

}

##################
# Subnet creation
##################
resource "aws_subnet" "mysubnet-1" {
  cidr_block              = "${module.shared_vars.cidr1_id}"
  vpc_id                  = "${local.vpcid}"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                  = "mysubnet-1-${module.shared_vars.env_suffix}"
  }
}

resource "aws_subnet" "mysubnet-2" {
  cidr_block              = "${module.shared_vars.cidr2_id}"
  vpc_id                  = "${local.vpcid}"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name                  = "mysubnet-2-${module.shared_vars.env_suffix}"
  }
}

resource "aws_subnet" "mysubnet-3" {
  cidr_block              = "${module.shared_vars.cidr3_id}"
  vpc_id                  = "${local.vpcid}"
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name                  = "mysubnet-3-${module.shared_vars.env_suffix}"
  }
}

##############
# Route table
##############
resource "aws_route_table" "myroutetable" {
  vpc_id                  = "${local.vpcid}"

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = "${aws_internet_gateway.mygateway.id}"
  }

  tags = {
    Name                  = "myroutetable-${module.shared_vars.env_suffix}"
  }
}

#########################
# Route table association
#########################
resource "aws_main_route_table_association" "mymainrtbassociation" {
  route_table_id          = "${aws_route_table.myroutetable.id}"
  vpc_id                  = "${local.vpcid}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "mygateway" {
  vpc_id                  = "${local.vpcid}"

  tags = {
    Name                  = "mygateway-${module.shared_vars.env_suffix}"
  }
}

##################
# Security Groups
##################
resource "aws_security_group" "publicsg" {
  name                    = "publicsg_${module.shared_vars.env_suffix}"
  description             = "publicsg for ELB ${module.shared_vars.env_suffix}"
  vpc_id                  = "${local.vpcid}"

  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  egress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "privatesg" {
  name                    = "privatesg_${module.shared_vars.env_suffix}"
  description             = "privatesg for EC2 ${module.shared_vars.env_suffix}"
  vpc_id                  = "${local.vpcid}"

  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    security_groups       = ["${aws_security_group.publicsg.id}"]
  }

  egress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

#########################################
#Output values - other modules can access
#########################################
output "publicsg_id"{
  value                   = "${aws_security_group.publicsg.id}"
}

output "privatesg_id"{
  value                   = "${aws_security_group.privatesg.id}"
}

output "vpcid"{
	value 			      = "${local.vpcid}"
}

output "publicsubnetid1" {
  value                   = "${local.publicsubnetid1}"
}

output "publicsubnetid2" {
  value                   = "${local.publicsubnetid2}"
}

output "privatesubnetid" {
  value                   = "${local.privatesubnetid}"
}