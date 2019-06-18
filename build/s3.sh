#!/bin/bash

#Upload all directories to S3

s3bucket="jrivera-cf-templates-codecommit"
echo "Removing files"
aws s3 rm s3://$s3bucket/ --recursive

echo "Uploading files"
cd ..
aws s3 cp . s3://$s3bucket/ --recursive --exclude "images" --exclude ".*" --exclude "s3.sh"

echo "Done"
