#!/bin/bash

# Script to create ecr repo, push docker image and upload SSL certificate to IAM

echo "Login to ECR"
eval $(aws ecr get-login --no-include-email)

#Create openresty repository
echo "Creating Openresty Repo"
OPENRESTYREPO=$(aws ecr create-repository --repository-name myopenresty --output text --query 'repository' | cut -f5)
echo "Creating PHP Repo"
#Create php repository
PHPREPO=$(aws ecr create-repository --repository-name myphp --output text --query 'repository' | cut -f5)

cd ..
touch .env
echo "OPENRESTYREPO=$OPENRESTYREPO" >> .env
echo "PHPREPO=$PHPREPO" >> .env

docker-compose build
docker-compose push

filename=".env"
echo ""
echo "============================================================================================="
echo "OpenResty and PHP Repo URLs, save it because will be needed for Cloudformation Parameters"
echo "============================================================================================="
echo ""
while read -r line; do
    echo "$line:latest"
done < "$filename"

echo ""
echo "============================================================================================="
echo "============================================================================================="

# Create a dummy Certificate and upload it to IAM
echo ""
echo ""
echo "============================================================================================="
echo "Creating SSL Certificate"
echo "============================================================================================="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/CN=dummy-ssl' -keyout dummy.key -out dummy.crt

echo ""
echo "============================================================================================="
echo "Uploading certificate to AWS IAM for ALB Listener"
echo "============================================================================================="
aws iam upload-server-certificate --server-certificate-name dummycert\
 --certificate-body file://dummy.crt --private-key file://dummy.key 1> /dev/null
 echo ""
 echo "Certificate successfuly uploaded to AWS IAM"

# Remove files created and not needed anymore
 rm -rf .env dummy.key dummy.crt
