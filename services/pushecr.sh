#!/bin/bash

echo Login to ECR
eval $(aws ecr get-login --region us-east-2 --no-include-email)

