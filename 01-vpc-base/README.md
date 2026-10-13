# 01 — VPC Base

This blueprint provisions the networking layer on AWS, engineered to meet requirements for high availability, multi-tier security isolation, and remote state governance.

The objective of this module is to serve as an isolated and stable foundation to support downstream workloads (such as EC2 instances, ECS clusters, or relational databases), decoupling core network infrastructure from compute layers.

## 📐 Network Topology and Multi-AZ Architecture

The topology deploys a Virtual Private Cloud (VPC) spanning two Availability Zones (`us-east-1a` and `us-east-1b`), segmented into three distinct tiers to enforce traffic isolation and adherence to the principle of least privilege:

| Identifier (Key) | Tier | CIDR Block | Availability Zone (AZ) | Routing / Association | 
| ----- | ----- | ----- | ----- | ----- | 
| `pub-subnet-a` | Public | `172.16.10.0/24` | `us-east-1a` | Public Route Table $\rightarrow$ Internet Gateway (IGW) | 
| `pub-subnet-b` | Public | `172.16.20.0/24` | `us-east-1b` | Public Route Table $\rightarrow$ Internet Gateway (IGW) | 
| `priv-app-subnet-a` | Private (App) | `172.16.11.0/24` | `us-east-1a` | Private Route Table (Isolated) | 
| `priv-app-subnet-b` | Private (App) | `172.16.21.0/24` | `us-east-1b` | Private Route Table (Isolated) | 
| `priv-db-subnet-a` | Private (Database) | `172.16.12.0/24` | `us-east-1a` | Private Route Table (Isolated) | 
| `priv-db-subnet-b` | Private (Database) | `172.16.22.0/24` | `us-east-1b` | Private Route Table (Isolated) | 

## 🛡️ Applied Networking & Security Concepts

* **External Network Edge (Internet Gateway):** The Internet Gateway (IGW) serves as the VPC edge gateway to the public internet, associated strictly with the public subnet route table.

* **Strict Private Layer Isolation:** Application and database subnets have no direct routes to the Internet Gateway nor dynamic public IPv4 allocation. Workloads provisioned in these subnets cannot be directly accessed from the public internet.

* **Multi-AZ Fault Tolerance:** Each functional layer provides redundant presence across two distinct availability zones, allowing fault-tolerant designs against the total loss of an individual AZ.

## 🛠️ IaC & Terraform Implementation Patterns

* **Dynamic Subnet Provisioning with `for_each`:** All six subnets are managed by a single `aws_subnet` resource block iterating over a structured object map defined in `variables.tf`. This avoids manual boilerplate code and simplifies subnet management.

* **Declarative Route Associations:** Subnet association mapping utilizes inline attribute filtering (`for k, v in var.subnets : k => v if v.is_public`), binding public and private route tables dynamically without manual redundancy.

* **Centralized State Governance:** State files are stored remotely in an Amazon S3 backend with bucket versioning enabled, ensuring state integrity and change tracking.

* **Output Decoupling:** Resources needed by downstream modules are exported through `outputs.tf` for consumption via `data "terraform_remote_state"`, eliminating hardcoded dependencies across layers.

## 📁 Directory Structure

```
01-vpc-base/
├── main.tf          # AWS provider configuration and S3 remote state backend
├── variables.tf     # VPC CIDR block and structured subnet object map
├── network.tf       # VPC, Subnets, IGW, Route Tables, and Associations
├── outputs.tf       # Exported VPC IDs and subnet maps
└── README.md        # Technical module documentation

```

## 🚀 Execution Guide

### 1. Prerequisites

Verify that your AWS CLI profile is set up and the target S3 bucket for remote state is available:

```
export AWS_PROFILE="terraform"

```

### 2. Initialization and Deployment

```
# Initialize providers and connect to the S3 remote backend
terraform init

# Validate execution plan and proposed resources
terraform plan

# Apply infrastructure changes to AWS
terraform apply

```

## 📤 Exported Outputs

Downstream modules can consume the following outputs using `data "terraform_remote_state"`:

* `vpc_id`

* `subnet_ids`:

  * `subnet_ids["pub-subnet-a"]`

  * `subnet_ids["pub-subnet-b"]`

  * `subnet_ids["priv-app-subnet-a"]`

  * `subnet_ids["priv-app-subnet-b"]`

  * `subnet_ids["priv-db-subnet-a"]`

  * `subnet_ids["priv-db-subnet-b"]`