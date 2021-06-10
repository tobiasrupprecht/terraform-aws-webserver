
#Provider
provider "aws" {
  profile = "default"
  region  = var.region
}

#VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.region}-${var.env}-VPC"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.region}-${var.env}-Internet-Gateway"
  }
}

#Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

#NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.main.id
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name = "${var.region}-${var.env}-NAT"
  }
}

#Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.region}-${var.env}-Public-Route-Table"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

#Route table association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

#Subnet (public)
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.region}-${var.env}-Public-Subnet"
  }
}

#Security Group - allow ssh & http
resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #  description = "For SSH Connection"
  # from_port   = 22
  #to_port     = 22
  # protocol    = "tcp"
  # cidr_blocks = ["0.0.0.0/0"]
  #}
  ingress {
    description = "For Webserver reachability"
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

  tags = {
    Name = "${var.region}-${var.env}-SG"
  }
}

#Keypair for authenticating with remote-exec
#resource "aws_key_pair" "my_key" {
# key_name   = "my_key"
# public_key = file(".ssh/id_rsa.pub")
# }

#Webserver
resource "aws_instance" "app_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.allow.id]
  #key_name                    = aws_key_pair.my_key.key_name

  #user_data     = <<-EOF
  #               #!/bin/bash
  #              sudo su
  #             yum -y install httpd
  #            echo "<p> Webserver with user_data! </p>" >> /var/www/html/index.html
  #           sudo systemctl enable httpd
  #          sudo systemctl start httpd
  #         EOF

  #Remote Exec Provisioner to install Webserver (NGINX)
  # provisioner "remote-exec" {
  #  inline = [
  #    "sudo apt-get install -y nginx",
  #    "sudo /etc/init.d/nginx start",
  #  ]
  # }

  #Be aware which AMI you use --> need to have correct user!!!
  #connection {
  #  host        = self.public_ip
  #  type        = "ssh"
  #  user        = "ubuntu"
  #  private_key = file(".ssh/id_rsa")
  #  agent       = false
  #  timeout     = "1m"
  # }

  tags = {
    Name = "${var.region}-${var.env}-${var.instance_name}"
  }
}
