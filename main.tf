provider "aws" {
  region = "ap-south-1"
}

# Create a security group for SSH and HTTP access
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http_web"
  description = "Allow SSH and HTTP inbound traffic"

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

  # Add the rule to allow traffic on port 9090
  ingress {
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add the rule to allow traffic on port 9090
  ingress {
    from_port   = 9081
    to_port     = 9081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add the rule to allow traffic on port 9090
  ingress {
    from_port   = 9082
    to_port     = 9082
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
  ami                    = "ami-0ddfba243cbee3768"  # Update with the correct AMI ID
  instance_type          = "t2.micro"
  key_name               = "terraform"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  associate_public_ip_address = true
  tags = {
    Name = "MyPublicEC2Instance"
  }
}

# Run Ansible Playbook after instance creation
# resource "null_resource" "ansible_provision" {
#  depends_on = [aws_instance.my_instance]
#  provisioner "local-exec" {
#    command = <<EOT
#    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -e "ansible_python_interpreter=/usr/bin/python3" -i "${aws_instance.my_instance.public_ip}," --private-key terraform.pem install_docker.yml
#    EOT
#  }
#}

# Output the public IP
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "ssh_command" {
  value = "ssh -i terraform.pem ec2-user@${aws_instance.my_instance.public_ip}"
}

