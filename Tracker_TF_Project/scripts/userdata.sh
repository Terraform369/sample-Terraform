#!/bin/bash
sudo su
yum update -y
yum install httpd php -y
echo '<h1> Welcome to Tracker Portal</h1><br><br>' > /var/www/html/index.html
echo '<h2 align=center> I-9 COMPLIANCE, UNMATCHED</h2>' >> /var/www/html/index.html
sudo service httpd start

# sleep 15
# Write code to copy S3 bucket web application files to EC2
# Ex: aws s3 sync --quiet s3://tracker-devwebapp/ /var/www/html/