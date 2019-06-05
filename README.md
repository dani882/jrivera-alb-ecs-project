# Jesus Rivera's Trial project for Incsub using with AWS CloudFormation, Amazon ECS, and an Application Load Balancer


## Overview

![infrastructure-overview](images/architecture-overview.png)

The repository consists of a set of nested templates that deploy the following:

 - A tiered [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with public subnets, spanning an AWS region.
 - A highly available ECS cluster deployed across two [Availability Zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) in an [Auto Scaling](https://aws.amazon.com/autoscaling/) group and that are AWS SSM enabled.
 - Two interconnecting services deployed as [ECS services](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) (openresty and php-fpm). 
 - An [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) to the public subnets to handle inbound traffic.
 - ALB path-based routes for each ECS service to route the inbound traffic to the correct service.
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).
 - A [Lambda Function](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) and [Auto Scaling Lifecycle Hook](https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html) to [drain Tasks from your Container Instances](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html) when an Instance is selected for Termination in your Auto Scaling Group.

## Template details

The templates below are included in this repository and reference architecture:

| Template | Description |
| --- | --- | 
| [master.yaml](master.yaml) | This is the master template - deploy it to CloudFormation and it includes all of the others automatically. |
| [infrastructure/vpc.yaml](infrastructure/vpc.yaml) | This template deploys a VPC with a pair of public and private subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. It deploys a pair of NAT gateways (one in each zone), and default routes for them in the private subnets. |
| [infrastructure/security-groups.yaml](infrastructure/security-groups.yaml) | This template contains the [security groups](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html) required by the entire stack. They are created in a separate nested template, so that they can be referenced by all of the other nested templates. |
| [infrastructure/load-balancers.yaml](infrastructure/load-balancers.yaml) | This template deploys an ALB to the public subnets, which exposes the various ECS services. It is created in in a separate nested template, so that it can be referenced by all of the other nested templates and so that the various ECS services can register with it. |
| [infrastructure/ecs-cluster.yaml](infrastructure/ecs-cluster.yaml) | This template deploys an ECS cluster to the private subnets using an Auto Scaling group and installs the AWS SSM agent with related policy requirements. |
| [infrastructure/lifecyclehook.yaml](infrastructure/lifecyclehook.yaml) | This template deploys a Lambda Function and Auto Scaling Lifecycle Hook to drain Tasks from your Container Instances when an Instance is selected for Termination in your Auto Scaling Group.
| [services/product-service/service.yaml](services/product-service/service.yaml) | This is an example of a long-running ECS service that serves a JSON API of products. For the full source for the service, see [services/product-service/src](services/product-service/src).|
| [services/website-service/service.yaml](services/website-service/service.yaml) | This is an example of a long-running ECS service that needs to connect to another service (product-service) via the load-balanced URL. We use an environment variable to pass the product-service URL to the containers. For the full source for this service, see [services/website-service/src](services/website-service/src). |

After the CloudFormation templates have been deployed, the [stack outputs](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) contain a link to the load-balanced URL of the deployed application.

![stack-outputs](images/stack-outputs.png)

The ECS instances should also appear in the Managed Instances section of the EC2 console.

## How do I...?

### Get started and deploy this into my AWS account

You can launch this CloudFormation stack in your account:

| AWS Region | Short name | | 
| -- | -- | -- |
| US East (Ohio) | us-east-2 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| US East (N. Virginia) | us-east-1 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| US GovCloud | us-gov-west-1 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.amazonaws-us-gov.com/cloudformation/home?region=us-gov-west-1#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| US West (Oregon) | us-west-2 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| US West (N. California) | us-west-1 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| Canada (Central) | ca-central-1 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ca-central-1#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| EU (London) | eu-west-2 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| EU (Ireland) | eu-west-1 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |
| Asia Pacific (Sydney) | ap-southeast-2 | [![cloudformation-launch-button](images/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/new?stackName=Production&templateURL=https://s3.amazonaws.com/ecs-refarch-cloudformation/master.yaml) |


### Create a new ECS service

1. Push your container to a registry somewhere (e.g., [Amazon ECR](https://aws.amazon.com/ecr/)).
2. Copy one of the existing service templates in [services/*](/services).
3. Update the `ContainerName` and `Image` parameters to point to your container image instead of the example container.
4. Increment the `ListenerRule` priority number (no two services can have the same priority number - this is used to order the ALB path based routing rules).
5. Copy one of the existing service definitions in [master.yaml](master.yaml) and point it at your new service template. Specify the HTTP `Path` at which you want the service exposed. 
6. Deploy the templates as a new stack, or as an update to an existing stack.


### Adjust the Auto Scaling parameters for ECS hosts and services

The Auto Scaling group scaling policy provided by default launches and maintains a cluster of 4 ECS hosts distributed across two Availability Zones (min: 4, max: 4, desired: 4).

It is ***not*** set up to scale automatically based on any policies (CPU, network, time of day, etc.). 
  
If you would like to configure policy or time-based automatic scaling, you can add the [ScalingPolicy](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-policy.html) property to the AutoScalingGroup deployed in [infrastructure/ecs-cluster.yaml](infrastructure/ecs-cluster.yaml#L69).

As well as configuring Auto Scaling for the ECS hosts (your pool of compute), you can also configure scaling each individual ECS service. This can be useful if you want to run more instances of each container/task depending on the load or time of day (or a custom CloudWatch metric). To do this, you need to create [AWS::ApplicationAutoScaling::ScalingPolicy](http://docs.aws.amazon.com/pt_br/AWSCloudFormation/latest/UserGuide/aws-resource-applicationautoscaling-scalingpolicy.html) within your service template.


### VPC and subnet IP ranges

This set of templates deploys the following network design:

| Item | CIDR Range | Usable IPs | Description |
| --- | --- | --- | --- |
| VPC | 10.0.0.0/16 | 65,536 | The whole range used for the VPC and all subnets |
| Public Subnet | 10.0.0.0/24 | 256 | The public subnet in the first Availability Zone |
| Public Subnet | 10.0.1.0/24 | 256 | The public subnet in the second Availability Zone |


### Spot Instances and the Hibernate Agent.

In order to use Spot with this template, you will need to enable ```SpotPrice``` under the ```AWS::AutoScaling::LaunchConfiguration``` or add in ```AWS::EC2::SpotFleet``` support.  To fully use Hibernation with Spot instances, please review [Spot Instance Interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html).


## License

Copyright 2011-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

[http://aws.amazon.com/apache2.0/](http://aws.amazon.com/apache2.0/)

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


