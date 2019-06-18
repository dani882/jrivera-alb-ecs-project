# Jesus Rivera's Trial project using with AWS CloudFormation, Amazon ECS, and an Application Load Balancer


## Overview


A basic PHP Application that display php information using phpversion() method.

The application is based on two docker images(openresty and php-fpm) and have been modified using Dockerfile and docker-compose to be linked each other.

The application is running in a ECS cluster that needs a minimum of two instances at all times (in separate Availability
zones for redundancy) and a maximum of 5 scaling up automatically the number of instances in case the cpu usage is higher than 75% for more than 1 minute and scale down if the cpu usage drops below 40% for more than 20 minutes.

The repository consists of a set of nested templates that deploy the following:

 - A tiered [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with two public subnets, spanning an AWS region.
 - A highly available ECS cluster deployed across two [Availability Zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) in an [Auto Scaling](https://aws.amazon.com/autoscaling/) group and that are AWS SSM enabled.
 - Two services in a cluster for HTTP and HTTPS listener respectively.
 - An [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) to the public subnets to handle inbound traffic.
 - ALB path-based routes for each ECS service to route the inbound traffic to the correct service(http and https).
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).
 - A [Lambda Function](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) and [Auto Scaling Lifecycle Hook](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html) to [drain Tasks from your Container Instances](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html) when an Instance is selected for Termination in your Auto Scaling Group.

## Template details

The templates below are included in this repository and reference architecture:

| Template | Description |
| --- | --- | 
| [master.yaml](master.yaml) | This is the master template - deploy it to CloudFormation and it includes all of the others automatically. |
| [infrastructure/vpc.yaml](infrastructure/vpc.yaml) | This template deploys a VPC with a pair of public subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. |
| [infrastructure/security-groups.yaml](infrastructure/security-groups.yaml) | This template contains the [security groups](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html) required by the entire stack. They are created in a separate nested template, so that they can be referenced by all of the other nested templates. |
| [infrastructure/load-balancers.yaml](infrastructure/load-balancers.yaml) | This template deploys an ALB to the public subnets, which exposes the various ECS services. It is created in in a separate nested template, so that it can be referenced by all of the other nested templates and so that the various ECS services can register with it. |
| [infrastructure/ecs-cluster.yaml](infrastructure/ecs-cluster.yaml) | This template deploys an ECS cluster to the public subnets using an Auto Scaling group using Launch Template for mixed Spot and On-demand instances and also installs the AWS SSM agent with related policy requirements. |
| [infrastructure/lifecyclehook.yaml](infrastructure/lifecyclehook.yaml) | This template deploys a Lambda Function and Auto Scaling Lifecycle Hook to drain Tasks from your Container Instances when an Instance is selected for Termination in your Auto Scaling Group.
| [services/service.yaml](services/service.yaml) | This is the two ECS services are created used for display the phpinfo via the load-balanced URL. 

After the CloudFormation templates have been deployed, the [stack outputs](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) contain a link to the load-balanced URL of the deployed application.

The ECS instances should also appear in the Managed Instances section of the EC2 console.

### VPC and subnet IP ranges

This set of templates deploys the following network design:

| Item | CIDR | Description |
| --- | --- | --- |
| VPC | 10.0.0.0/16 | The whole range used for the VPC and all subnets |
| Public Subnet 1 | 10.0.0.0/24 | The public subnet in the first Availability Zone |
| Public Subnet 2 | 10.0.1.0/24 | The public subnet in the second Availability Zone |

## Provisioning infrastructure

### Tools needed:
We need to have aws-cli configured, docker and docker-compose installed.

### ECR Repository and Certificate
First step we need to do is create Two repositories and a SSL Certificate that are needed for these project

- Clone this repository
- Go to build/ folder
- Execute ``` bash prepenv.sh ``` to create repo, push docker images and create ssl certificate
- Once script have finished, It will show two URL ECR repo that will be needed to continue with the provisioning process. Copy it to any text editor and continue with the other steps.


### Deploy into AWS account

Now that ECR Repos and SSL Certificate are create you can launch this CloudFormation stack in your account to provision the infrastructure:

 [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=trial-project&templateURL=https://jrivera-cf-templates-codecommit.s3.us-east-2.amazonaws.com/master.yaml)


- In the parameter section, paste the url from prepenv script and continue.
