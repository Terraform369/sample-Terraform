#################################################################################
# 	AWS - Auto scaling Module - Creates Launch config, auto scaling group etc 	#
#	Author: Janaki			Version 0:	2nd May 2020							#
#							Version 1:	Added remote backend                 	#
#################################################################################

module "shared_vars" {
	source 					= "../shared_vars"
}

# These variables carry values from other modules
variable privatesg_id {}
variable publicsg_id {}
variable publicsubnetid1 {}
variable publicsubnetid2 {}
variable tg_arn {}


locals {
	env 					= "${terraform.workspace}"

	amiid_env = {
		default 			= "ami-0b59bfac6be064b78"
		production 			= "ami-0b59bfac6be064b78"
	}
	amiid 					= "${lookup(local.amiid_env, local.env)}"

	instancetype_env = {
		default 			= "t2.micro"
		production 			= "t2.medium"
	}
	instancetype 			= "${lookup(local.instancetype_env, local.env)}"

	keypairname_env = {
		default 			= "aws_project_tf_kp_staging"
		production 			= "aws_project_tf_kp_production"
	}
	keypairname 			= "${lookup(local.keypairname_env, local.env)}"

	asgdesired_env = {
		default 			= "1"
		production 			= "2"
	}
	asgdesired 				= "${lookup(local.asgdesired_env, local.env)}"

	asgmin_env = {
		default 			= "1"
		production 			= "2"
	}
	asgmin 					= "${lookup(local.asgmin_env, local.env)}"

	asgmax_env = {
		default 			= "2"
		production 			= "4"
	}
	asgmax 					= "${lookup(local.asgmax_env, local.env)}"

}

########################
# EC2 Instance Key pair
########################
# sourced public key into .pem file and placed it into the same folder
resource "aws_key_pair" "aws_project_tf_kp" {
  public_key            = "${file("scripts/aws_project_tf_kp.pem")}"
  key_name              = "${local.keypairname}"
}

##################################
# Launch config - with ami details
##################################
resource "aws_launch_configuration" "trackerapp_lc" {
  name          			= "trackerapp_lc_${local.env}"
  image_id      			= "${local.amiid}"
  instance_type 			= "${local.instancetype}"
  key_name					= "${local.keypairname}"
  user_data					= "${file("scripts/userdata.sh")}"
  security_groups 			= ["${var.publicsg_id}"]
}

###################
# Auto Scale Group
###################
resource "aws_autoscaling_group" "trackerapp_asg" {
  name                 		= "trackerapp_asg_${module.shared_vars.env_suffix}"
  max_size             		= "${local.asgmax}"
  min_size             		= "${local.asgmin}"
  desired_capacity	  		= "${local.asgdesired}"
  launch_configuration 		= "${aws_launch_configuration.trackerapp_lc.name}"
  vpc_zone_identifier  		= ["${var.publicsubnetid1}"]
  target_group_arns	   		= ["${var.tg_arn}"]

  tags = [
    {
      key                 	= "Name"
      value               	= "trackerapp_${module.shared_vars.env_suffix}"
      propagate_at_launch 	= true
    },
    {
      key                 	= "Environment"
      value               	= "${module.shared_vars.env_suffix}"
      propagate_at_launch 	= true
    }
  ]
}

#########################################################################################
# Auto Scale policies - based on cloud watch alerts, instances will get added or removed
#########################################################################################

# To do - write code here to implement Scaling policies or up & down