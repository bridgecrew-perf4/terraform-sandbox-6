**Description**
  - A sandbox for testing ECS Fargate.

**Required**

AWS Credentials



**Steps**

export AWS* variables

```
e.g.

export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxx
export AWS_DEFAULT_REGION=eu-west-1
```

Create ecr repo

```
e.g.

cd ecrs

terraform init
terraform plan
terraform apply -auto-approve
terraform

```

Create app and push to ECR repo

```
cd flask

export AWS_ACCOUNT_ID=xxxxxxxxx
export AWS_DEFAULT_REGION=eu-west-1
export ECR_REPO=sample-app
export DOCKER_IMAGE_TAG=latest

aws ecr get-login --no-include-email

***************************************************************************************
************take the string and login to ecr with it **********************************
***************************************************************************************

sudo docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${DOCKER_IMAGE_TAG} . -f Dockerfile || exit 9
sudo docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO}:${DOCKER_IMAGE_TAG}

```

Create a Private VPC without internet gateway or nat.

```

cd networking

terraform init
terraform plan
terraform apply -auto-approve
terraform

```
Take note of the vpc_id, route_table_id, and subnet_id

Fill out the exports file in fargate and vpc_endpoints directories

```
vim exports
source exports
```


Create VPC endpoints and Gateway (s3)

```
cd vpc_endpoints

terraform init
terraform plan
terraform apply -auto-approve

```

Create ECS cluster and create service

Note: used platform_version 1.3.0 instead of 1.4.0 because 1.4.0 also requires ssm endpoint.  
we can upgrade later.

```
cd fargate

terraform init
terraform plan
terraform apply -auto-approve

```

Issue with conditional

**ERROR (CannotPullContainerError: error pulling image conf)**

**REFERENCE - does not work it seems
https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html**


if you add the statement below to s3.tf from s3-with-conditionals, it stops working and 
has the error shown above. 

```
diff s3.tf s3-with-conditionals 

>             "Condition": {"StringEquals":
>               {"aws:PrincipalOrgID":["o-xxxxx"]}
>             },


```


