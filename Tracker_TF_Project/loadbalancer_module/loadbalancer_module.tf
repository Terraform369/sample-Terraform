#################################################################################
# 	AWS - Load balancer Module - Creates load balancer, target group etc      	#
#	Author: Janaki			Version 0:	2nd May 2020							#
#							                                                 	#
#################################################################################

# These variables carry values from other modules
variable publicsg_id {}
variable privatesg_id {}
variable vpcid {}
variable publicsubnetid1 {}
variable publicsubnetid2 {}

module "shared_vars"{
  source                 = "../shared_vars"
}

################
# Load balancer
################
resource "aws_lb" "trackerapp_alb" {
  name                  = "trackerapp-alb-${module.shared_vars.env_suffix}"
  internal              = false
  load_balancer_type    = "application"
  security_groups       = ["${var.publicsg_id}"]
  subnets               = ["${var.publicsubnetid1}", "${var.publicsubnetid2}"]

  enable_deletion_protection = false

  tags = {
    Environment         = "${module.shared_vars.env_suffix}"
  }
}

############################################
# Load balancer target group, Health checks
############################################
resource "aws_lb_target_group" "trackerapp_http_tg" {
  name                  = "trackerapp-http-tg-${module.shared_vars.env_suffix}"
  port                  = 80
  protocol              = "HTTP"
  vpc_id                = "${var.vpcid}"
  health_check {
    path                = "/icons/apache_pb2.gif"
    interval            = 5
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
  tags = {
    Name                = "trackerapp_tg-${module.shared_vars.env_suffix}"
  }
}

resource "aws_lb_listener" "http_listener_80" {
  load_balancer_arn     = "${aws_lb.trackerapp_alb.arn}"
  port                  = "80"
  protocol              = "HTTP"

  default_action {
    type                = "forward"
    target_group_arn    = "${aws_lb_target_group.trackerapp_http_tg.arn}"
  }
}

# Output values - so other modules can access

output "tg_arn" {
  value                 = "${aws_lb_target_group.trackerapp_http_tg.arn}"
}

output "loadbalancer_url" {
  value                 = "${aws_lb.trackerapp_alb.dns_name}"
}

