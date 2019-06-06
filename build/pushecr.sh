#!/bin/bash

# Script to login, create ecr repo and push docker image

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

rm -rf .env