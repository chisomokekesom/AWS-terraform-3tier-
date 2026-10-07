# AWS 3-Tier Architecture with Terraform

This project deploys a highly available and scalable 3-tier AWS architecture using Terraform.

## Architecture

![AWS 3-Tier Terraform Architecture](images/aws-3tier-architecture.png)

### Architecture Overview

The infrastructure is deployed across multiple Availability Zones and consists of:

- **VPC** – Provides an isolated network for the infrastructure.
- **Public Subnets** – Host the Application Load Balancer and NAT Gateway.
- **Application Load Balancer (ALB)** – Distributes incoming traffic across application servers.
- **Private Subnets** – Host EC2 instances running the application tier.
- **Auto Scaling Group** – Automatically scales EC2 instances based on demand.
- **Amazon RDS MySQL** – Provides the private database tier.
- **NAT Gateway** – Allows private resources to access the internet without exposing them publicly.
- **Security Groups** – Control traffic between the ALB, EC2, and RDS tiers.
- **IAM** – Provides permissions for AWS resources.

### Traffic Flow

Users → Internet Gateway → Application Load Balancer → EC2 Auto Scaling Group → Amazon RDS

The EC2 and RDS resources remain in private subnets, reducing direct exposure to the internet.
