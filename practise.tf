terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.1"
        }
    }
}

# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
}

# Configure the resource block for AWS EC2 instance
resource "tls_private_key" "remote_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

## This resources block creates the public key
resource "aws_key_pair" "remote_key" {
    key_name = "remote_key"
    public_key = tls_private_key.remote_key.public_key_openssh
}

// save the private key
resource "local_file" "remote_key" {
    content = tls_private_key.remote_key.private_key_pem
    filename = "remote_key.pem"
}

## This is the resource block for creating EC2 instance
resource "aws_instance" "myec2" {
    ami = "ami-0e86e20dae9224db8"
    count = 2
    key_name = aws_key_pair.remote_key.key_name
    associate_public_ip_address = true
    instance_type = "t2.micro"
    tags = {
      Name= "terra-instance"
    }
}