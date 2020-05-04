provider "aws" {
	region 				= "us-east-2"
}
/*Commenting the code to have a remote S3 backend with DynamoDb table as it would need the table  abd bucket to be created
/*terraform {
	backend "s3" {
		encrypt = true
		bucket = "codesantaclara"
		dynamodb_table = "tflocktable"
		key = "test.tfstate"
	}
}
*/
module "network_module"{
	source 				= "./network_module"
}

module "loadbalancer_module"{
	source 				= "./loadbalancer_module"
	publicsg_id 		= "${module.network_module.publicsg_id}"
	privatesg_id 		= "${module.network_module.privatesg_id}"
	vpcid 				= "${module.network_module.vpcid}"
	publicsubnetid1 	= "${module.network_module.publicsubnetid1}"
	publicsubnetid2 	= "${module.network_module.publicsubnetid2}"
}

module "autoscaling_module"{
	source 				= "./autoscaling_module"
	privatesg_id 		= "${module.network_module.privatesg_id}"
	publicsg_id 		= "${module.network_module.publicsg_id}"
	tg_arn 				= "${module.loadbalancer_module.tg_arn}"
	publicsubnetid1 	= "${module.network_module.publicsubnetid1}"
	publicsubnetid2 	= "${module.network_module.publicsubnetid2}"
}

output "vpcid" {
	value 				= "${module.network_module.vpcid}"
}

output "loadbalancer_url" {
	value 				= "${module.loadbalancer_module.loadbalancer_url}"
}