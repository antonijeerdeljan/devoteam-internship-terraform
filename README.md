# Cloud Internship - Infrastructure Deployment
## Overview
This repository contains Terraform code for deploying and managing infrastructure on Google Cloud Platform (GCP) for the Cloud Internship project at Devoteam. It sets up networking, firewall rules, VM templates, instance groups, health checks, load balancers, and related configurations.

## Key Concepts
+ VPC & Subnetworks: Isolated virtual networks and segmented IP ranges for finer control.
+ Firewall Rules: Control ingress and egress traffic to instances.
+ Instance Templates & Group Managers: Templates for VM instances and management of instance groups.
+ Health Checks & Load Balancers: Monitor instance health and distribute traffic for high availability.
+ URL Mapping & Proxies: Route requests to backend services using URL maps and proxies.
## Getting Started
Install Terraform (v0.12.x or later).
Clone this repository and navigate to it.
Configure variables in terraform.tfvars.
Run `terraform init` and `terraform apply` to deploy the infrastructure.
Ensure proper GCP permissions and credentials are set up.
