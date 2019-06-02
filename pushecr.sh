#!/bin/bash

# Script to login, create ecr repo and push docker image
echo Login to ECR
eval $(aws ecr get-login --region us-east-2 --no-include-email)



##############################################################
##############################################################

#!/bin/bash
if (( "$#" != 1 ))
then
    echo "Usage:
./ecr_push [environment]"
exit 1
fi
if [[ $@ != acceptance && $@ != staging && $@ != production ]] ;
then
  echo "Environment must be either Acceptance, Staging or Production."
  exit 1
elif [[ $@ = staging || acceptance ]] ;
then
 AWS_ACCOUNT=XXXXXXXXXXXX
elif [[ $@ = production ]] ;
then
  AWS_ACCOUNT=XXXXXXXXXXXX
fi
REPO="$AWS_ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/rails_application-$@"
IMAGE=$REPO:latest-$@
$(aws ecr get-login --no-include-email --region $AWS_REGION)
docker build -t $IMAGE .
docker push $IMAGE