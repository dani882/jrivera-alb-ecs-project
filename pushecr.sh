#!/bin/bash

# Script to login, create ecr repo and push docker image
echo Login to ECR
eval $(aws ecr get-login --region us-east-2 --no-include-email)



