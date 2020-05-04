Terraform code for complete Infra such as VPC, Subnet, SG, Routes, IGT, route table associations, vpc flow logs, flow logs into S3 bucket, ec2 instance, load balancer, load balancer  stickness


*** AWS IAM User needs to be created and programmatic access needs to be enabled for this user 
*** WORKING CODE - wait for couple of minutes and then access LB url to access the web application

*** LB stickiness and VPC Flow Log, move Flow Logs to S3 bucket are disabled in the code, enable it when required

*** Format, tagging, comments etc are done

*** It will print EC2 dns, Public IP, LB Url etc, so we can directly access the LB URL without logging into Console

*** .pem, userdata.sh are bundled with this, so we need to extract and run

	terraform init
	terraform validate
	terraform plan	
	terraform apply --auto-approve

*** Run: terraform destory --auto-approve ---> to destroy entire infrastructure


## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.23 |
| aws | ~> 2.53 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

