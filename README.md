# AWS 3-Tier Network Infrastructure with Terraform

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-purple) ![AWS](https://img.shields.io/badge/AWS-Provider-orange)

This repository contains a modular Terraform configuration to deploy a secure, scalable **3-Tier Network Architecture** on AWS. It is designed to host web applications with strict separation between public, application, and database layers.

## 🏗 Architecture Overview

The module creates a Virtual Private Cloud (VPC) with **6 Subnets** spread across Availability Zones for high availability:

1.  **Tier 1: Public Layer (Frontend)**
    * **Components:** 2 Public Subnets, Internet Gateway (IGW).
    * **Purpose:** Hosts Load Balancers, Bastion Hosts, or Frontend Servers.
    * **Connectivity:** Direct access to/from the Internet.

2.  **Tier 2: Private Layer (Application)**
    * **Components:** 2 Private Subnets, NAT Gateway.
    * **Purpose:** Hosts Application Servers (EC2/Containers).
    * **Connectivity:** Can access the internet for updates (via NAT) but **cannot** be reached from the outside.

3.  **Tier 3: Internal Layer (Database)**
    * **Components:** 2 Internal Subnets.
    * **Purpose:** Hosts RDS Databases, ElastiCache, or sensitive internal APIs.
    * **Connectivity:** Completely isolated. No internet access (Ingress or Egress). Only accessible from Tier 1 or Tier 2.

## 📂 Project Structure

```text
.
├── main.tf                # Root configuration calling the module
├── vpc_module/            # The reusable Network Module
│   ├── main.tf            # Core logic (VPC, Subnets, Gateways, Route Tables)
│   ├── variables.tf       # Input definitions
│   └── outputs.tf         # Output definitions (VPC ID, Subnet IDs)
├── .gitignore             # Files excluded from Git
└── README.md              # Project documentation
```

## 🚀 How to Deploy

### Prerequisites
* [Terraform](https://www.terraform.io/downloads.html) installed.
* AWS CLI configured with credentials (`aws configure`).

### Steps
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Hondanx/terraform-aws-network.git
    cd terraform-aws-network
    ```

2.  **Initialize Terraform:**
    Downloads the necessary providers and initializes the local module.
    ```bash
    terraform init
    ```

3.  **Review the Plan:**
    See what resources will be created.
    ```bash
    terraform plan
    ```

4.  **Deploy:**
    Create the infrastructure on AWS.
    ```bash
    terraform apply -auto-approve
    ```

## ⚙️ Configuration (Inputs)

You can customize the network ranges in `main.tf`.

| Variable | Description | Default Example |
| :--- | :--- | :--- |
| `vpc_cidr` | The IP range for the entire VPC | `99.99.0.0/16` |
| `public_subnets` | List of CIDRs for the Public Tier | `["99.99.0.0/19", "99.99.32.0/19"]` |
| `private_subnets` | List of CIDRs for the Private Tier | `["99.99.64.0/19", "99.99.96.0/19"]` |
| `internal_subnets` | List of CIDRs for the DB Tier | `["99.99.128.0/19", "99.99.160.0/19"]` |

## 📤 Outputs

After applying, Terraform will output the following IDs for you to use in other projects:

* `vpc_id`: The ID of the created VPC.
* `public_subnet_ids`: IDs of the frontend subnets.
* `private_subnet_ids`: IDs of the application subnets.

## 🧹 Clean Up

To destroy all resources created by this project and avoid AWS charges:

```bash
terraform destroy -auto-approve
```

---
**Author:** Hondanx
