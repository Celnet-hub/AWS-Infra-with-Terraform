/**
This is a Terraform configuration file that creates a VPC, Public Subnet, Internet Gateway, Route Table, Route Table Association, Security Group, and EC2 Instance.
NOTE: 
- The main.tf file is the main configuration file for Terraform. It is the file that Terraform will use to create the resources.
- The main.tf file is written in Hashicorp Configuration Language (HCL).
- The main.tf file is a declarative file. It describes the desired state of the infrastructure.
- The main.tf file is a configuration file. It is not a script file. It is not a programming language file.
- The main.tf file is a text file. It is not a binary file.
- The main.tf file is a file that is written in a declarative language. It is not a file that is written in a procedural nor functional language.
- The major difference between a public subnet and a private subnet is that a public subnet has a route to the Internet Gateway, while a private subnet does not.

@Author: Chidubem Nwabuisi
@Date: 2021-09-13
@Version: 1.0
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

// AWS Provider
provider "aws" {
  region     = "us-east-1"
  shared_credentials_files = ["/home/dcn/.aws/credentials"]
  profile                 = "default"
}


// AWS VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {

    Name = "DevOpsVPC"
  }
}

// AWS Public Subnet
resource "aws_subnet" "devops_public_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {

    Name = "Devops-public-subnet"
  }
}

// AWS Internet Gateway
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

// AWS Route Table for the Public Subnet
resource "aws_route_table" "devops_public_route_table" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }
  tags = {
    Name = "devops_public_route_table"
  }
}

// AWS Route Table Association
resource "aws_route_table_association" "devops_public_route_table_association" {
  subnet_id      = aws_subnet.devops_public_subnet.id
  route_table_id = aws_route_table.devops_public_route_table.id
}

// AWS Security Group
resource "aws_security_group" "devops_security_group" {
  name        = "devops_security_group"
  description = "Allow SSH Only inbound traffic"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops_security_group"
  }

}

// AWS EC2 Instance in the Public Subnet
resource "aws_instance" "devops_instance" {
  ami                         = "ami-00874d747dde814fa"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.devops_public_subnet.id
  key_name                    = "AWSKEYPAIR"
  vpc_security_group_ids      = [aws_security_group.devops_security_group.id]
  associate_public_ip_address = true
  tags = {
    Name = "devops_instance"
  }
}

// AWS Output the Public IP of the EC2 Instance
output "Public_instance_Output" {
  value = [aws_instance.devops_instance.public_ip, aws_instance.devops_instance.private_ip, aws_instance.devops_instance.public_dns]
}


/*************************Creating the private subnetwork and NAT gateway**************************************/
// AWS Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Devops-private-subnet"
  }
}

// AWS EIP (Elastic IP)
resource "aws_eip" "devops_eip" {
  vpc = true
}

// AWS NAT Gateway and assign an EIP to it. Also set the subnet to the public subnet.
resource "aws_nat_gateway" "devops_nat_gateway" {
  allocation_id = aws_eip.devops_eip.id
  subnet_id     = aws_subnet.devops_public_subnet.id
  tags = {
    Name = "devops_nat_gateway"
  }
}

// AWS Route Table for the private sub-network
resource "aws_route_table" "devops_private_route_table" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops_nat_gateway.id // This is the only difference between the public route table and the private route table.
  }
  tags = {
    Name = "devops_private_route_table to NAT Gateway"
  }

}

// AWS Route Table Association for the private sub-network
resource "aws_route_table_association" "devops_private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.devops_private_route_table.id
}

// AWS Security Group for the private sub-network
resource "aws_security_group" "devops_private_security_group" {
  name        = "devops_private_security_group"
  description = "Allow SSH Only inbound traffic"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "ping"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops_private_security_group"
  }

}


// AWS EC2 Instance for the private sub-network
resource "aws_instance" "DevOps_Private_Server" {
  ami                         = "ami-00874d747dde814fa"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = "AWSKEYPAIR"
  vpc_security_group_ids      = [aws_security_group.devops_private_security_group.id]
  associate_public_ip_address = true
  tags = {
    Name = "devops_private_instance"
  }

}

// AWS Output the Public IP of the EC2 Instance
output "Privte_instance_Output" {
  value = [aws_instance.DevOps_Private_Server.public_ip, aws_instance.DevOps_Private_Server.private_ip, aws_instance.DevOps_Private_Server.public_dns]
}
