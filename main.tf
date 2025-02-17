provider "aws" {
  region = "ap-south-1"
}

# Create a Public VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyPublicVPC"
  }
}

# Create a public subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create a route table for public access
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a security group for SSH and HTTP access
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "my_instance" {
  ami                    = "ami-023a307f3d27ea427"  # Update with the correct AMI ID
  instance_type          = "t2.micro"
  key_name               = "terraform"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true

  tags = {
    Name = "MyPublicEC2Instance"
  }
}

# Run Ansible Playbook after instance creation
resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.my_instance]

  provisioner "local-exec" {
    command = <<EOT
      sleep 25  # Give some time for SSH service to start
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -e "ansible_python_interpreter=/usr/bin/python3" -i "${aws_instance.my_instance.public_ip}," --private-key terraform.pem install_docker.yml

    EOT
  }
}

# Output the public IP
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "ssh_command" {
  value = "ssh -i terraform.pem ubuntu@${aws_instance.my_instance.public_ip}"
}

