# BatchCheckLayerAvailability Grants permission to check the availability of multiple image layers in a specified registry and repository Read
# BatchDeleteImage    Grants permission to delete a list of specified images within a specified repository    Write
# BatchGetImage   Grants permission to get detailed information for specified images within a specified repository    Read
# CompleteLayerUpload Grants permission to inform Amazon ECR that the image layer upload for a specified registry, repository name, and upload ID, has completed  Write
# CreateRepository    Grants permission to create an image repository Write
# DeleteLifecyclePolicy   Grants permission to delete the specified lifecycle policy  Write
# DeleteRegistryPolicy    Grants permission to delete the registry policy Write
# DeleteRepository    Grants permission to delete an existing image repository    Write
# DeleteRepositoryPolicy  Grants permission to delete the repository policy from a specified repository   Write
# DescribeImageScanFindings   Grants permission to describe the image scan findings for the specified image   Read
# DescribeImages  Grants permission to get metadata about the images in a repository, including image size, image tags, and creation date Read
# DescribeRegistry    Grants permission to describe the registry settings Read
# DescribeRepositories    Grants permission to describe image repositories in a registry  List
# GetAuthorizationToken   Grants permission to retrieve a token that is valid for a specified registry for 12 hours   Read
# GetDownloadUrlForLayer  Grants permission to retrieve the download URL corresponding to an image layer  Read
# GetLifecyclePolicy  Grants permission to retrieve the specified lifecycle policy    Read
# GetLifecyclePolicyPreview   Grants permission to retrieve the results of the specified lifecycle policy preview request Read
# GetRegistryPolicy   Grants permission to retrieve the registry policy   Read
# GetRepositoryPolicy Grants permission to retrieve the repository policy for a specified repository  Read
# InitiateLayerUpload Grants permission to notify Amazon ECR that you intend to upload an image layer Write
# ListImages  Grants permission to list all the image IDs for a given repository  List
# ListTagsForResource Grants permission to list the tags for an Amazon ECR resource   List
# PutImage    Grants permission to create or update the image manifest associated with an image   Write
# PutImageScanningConfiguration   Grants permission to update the image scanning configuration for a repository   Write
# PutImageTagMutability   Grants permission to update the image tag mutability settings for a repository  Write
# PutLifecyclePolicy  Grants permission to create or update a lifecycle policy    Write
# PutRegistryPolicy   Grants permission to update the registry policy Write
# PutReplicationConfiguration Grants permission to update the replication configuration for the registry  Write
# ReplicateImage  Grants permission to replicate images to the destination registry   Write
# SetRepositoryPolicy Grants permission to apply a repository policy on a specified repository to control access permissions  Permissions management
# StartImageScan  Grants permission to start an image scan    Write
# StartLifecyclePolicyPreview Grants permission to start a preview of the specified lifecycle policy  Write
# TagResource Grants permission to tag an Amazon ECR resource Tagging
# UntagResource   Grants permission to untag an Amazon ECR resource   Tagging
# UploadLayerPart Grants permission to upload an image layer part to Amazon ECR   Write
###############################################################
#"ecr:BatchCheckLayerAvailability",
#"ecr:BatchDeleteImage",
#"ecr:BatchGetImage",
#"ecr:CompleteLayerUpload",
#"ecr:CreateRepository",
#"ecr:DeleteLifecyclePolicy",
#"ecr:DeleteRegistryPolicy",
#"ecr:DeleteRepository",
#"ecr:DeleteRepositoryPolicy",
#"ecr:DescribeImageScanFindings",
#"ecr:DescribeImages",
#"ecr:DescribeRegistry",
#"ecr:DescribeRepositories",
#"ecr:GetAuthorizationToken",
#"ecr:GetDownloadUrlForLayer",
#"ecr:GetLifecyclePolicy",
#"ecr:GetLifecyclePolicyPreview",
#"ecr:GetRegistryPolicy",
#"ecr:GetRepositoryPolicy",
#"ecr:InitiateLayerUpload",
#"ecr:ListImages",
#"ecr:ListTagsForResource",
#"ecr:PutImage",
#"ecr:PutImageScanningConfiguration",
#"ecr:PutImageTagMutability",
#"ecr:PutLifecyclePolicy",
#"ecr:PutRegistryPolicy",
#"ecr:PutReplicationConfiguration",
#"ecr:ReplicateImage",
#"ecr:SetRepositoryPolicy",
#"ecr:StartImageScan",
#"ecr:StartLifecyclePolicyPreview",
#"ecr:TagResource",
#"ecr:UntagResource",
#"ecr:UploadLayerPart",
###############################################################

resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = var.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.vpce.id]
  subnet_ids = [var.subnet_id]
 
  policy = <<EOF
{
    "Statement": [
        {
            "Sid": "GrantReadOnlyAccessToOrg",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:ListImages",
                "ecr:GetRepositoryPolicy",
                "ecr:GetAuthorizationToken",
                "ecr:DescribeRepositories",
                "ecr:DescribeImages",
                "ecr:DescribeImageScanFindings",
                "ecr:DescribeRegistry",
                "ecr:DescribeRepositories",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetLifecyclePolicy",
                "ecr:BatchGetImage",
                "ecr:GetRegistryPolicy",
                "ecr:ListTagsForResource"
            ],
            "Resource": [ "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.repo_name}",
                          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.repo_name}/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
 
  tags = {
    Name        = "dkr-endpoint"
    Environment = "dev"
  }
}
