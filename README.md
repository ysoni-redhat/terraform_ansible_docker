# Terraform and Ansible AWS Configuration

This project demonstrates how to use **Terraform** to provision AWS infrastructure and **Ansible** for configuration management. Specifically, we use Terraform to create an AWS EC2 instance, a VPC, a subnet, security groups, and route tables. After provisioning the instance, we use Ansible to install Docker, Docker Compose, and configure the EC2 instance with multiple Docker containers.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [Ansible](https://www.ansible.com/products/ansible)
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Account](https://aws.amazon.com/)
- SSH Key Pair (for connecting to the EC2 instance)
- [Python 3](https://www.python.org/downloads/) and [Pip](https://pip.pypa.io/en/stable/)

You should also configure your AWS credentials using `aws configure` if you haven't already.

## Project Overview

This project uses Terraform to:
1. Create a VPC with a public subnet.
2. Launch an EC2 instance in that subnet.
3. Configure the security group to allow SSH and HTTP traffic.
4. Install Docker and Docker Compose on the EC2 instance using Ansible.
5. Provision the EC2 instance to run three Docker containers.

The Ansible playbook `install_docker.yml` will:
1. Install Docker and Docker Compose.
2. Set up three Docker containers with specific configurations.
3. Clone an Ansible configuration from a GitHub repository for further configuration management.


## How to Set Up and Run the Project

### 1. Configure AWS CLI
Make sure AWS CLI is configured with appropriate credentials:
```bash
aws configure
```

### 2. Initialize Terraform
In the root of the project, initialize Terraform. This command will install necessary plugins and set up the working environment.
```bash
terraform init
```

### 3. Apply Terraform Configuration
Run the following command to apply the Terraform configuration, which will provision the AWS resources:
```bash
terraform apply
```

### 4. SSH into the EC2 Instance
Use the generated SSH command to connect to the EC2 instance:
```bash
ssh -i terraform.pem ec2-user@<PUBLIC_IP>
```

### 5. Verify Docker Containers
```bash
sudo docker ps
```

### 6. Navigate to the directory config inside the AWS instance:
```bash
cd config
ansible-playbook -i hosts main.yaml 
```

### 7. This will make 3 website live in each of the container respectively
* http://public_ip:9080
* http://public_ip:9081
* http://public_ip:9082





