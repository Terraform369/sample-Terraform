output "env_suffix"{
	value 			= "${local.env}"
}

output "regionname" {
	value = "${local.regionname}"
}

output "cidr_vpc_id" {
	value = "${local.cidr_vpc_id}"
}

output "cidr1_id" {
	value = "${local.cidr1_id}"
}

output "cidr2_id" {
	value = "${local.cidr2_id}"
}

output "cidr3_id" {
	value = "${local.cidr3_id}"
}

locals {
	env 			= "${terraform.workspace}"

	region_env = {
		default 	= "us-east-2"
		production	= "us-east-1"
	}
	regionname 		= "${lookup(local.region_env, local.env)}"

	cidr_vpc_env = {
		default		= "10.0.0.0/16"
	}
	cidr_vpc_id		= "${lookup(local.cidr_vpc_env, local.env)}"

	cidr1_env		= {
		default		= "10.0.1.0/24"
	}
	cidr1_id		= "${lookup(local.cidr1_env, local.env)}"

	cidr2_env		= {
		default		= "10.0.2.0/24"
	}
	cidr2_id		= "${lookup(local.cidr2_env, local.env)}"

	cidr3_env		= {
		default		= "10.0.3.0/24"
	}
	cidr3_id		= "${lookup(local.cidr3_env, local.env)}"
}
