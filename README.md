# Infrastructure Blueprints with Terraform and AWS

A collection of Infrastructure as Code (IaC) architectures for AWS using Terraform, designed following enterprise standards for modularity, high availability, and state governance.

The proposal is to decouple the network foundation layer from compute and data layers, allowing different workloads to consume the base infrastructure independently.

## General Architecture

> <Diagram under construction...>

The repository is structured into independent modules:

| Blueprint | Directory | Architecture Scope | Status |
| :--- | :--- | :--- | :--- |
| **01** | [`01-vpc-base`](./01-vpc-base/) | Network foundation with VPC, Multi-AZ public and private subnet segmentation, Internet Gateway, route tables, and remote backend. | ✅ Completed |
| **02** | | | |
| **03** | | | |
| **04** | | | |

## Prerequisites and State Backend (S3)

To ensure governance and safe concurrency locking, the tfstate is managed remotely in an S3 Bucket with versioning enabled.

Because Terraform requires the backend to be accessible during initialization, the bucket must exist in the AWS account prior to executing `terraform init`:

```bash
# 1. Set your configured AWS CLI profile
export AWS_PROFILE="YOUR-PROFILE"

# 2. Create the S3 bucket intended for remote state
aws s3api create-bucket --bucket "YOUR-BUCKET-TFSTATE" --region us-east-1

# 3. Enable bucket versioning for state resilience
aws s3api put-bucket-versioning --bucket "YOUR-BUCKET-TFSTATE" --versioning-configuration Status=Enabled
```