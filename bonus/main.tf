terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  tags = {
    Assignment = "github-actions-wordpress-rds-bonus"
    ManagedBy  = "Terraform"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "wordpress" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "wordpress-rds-bonus" })
}

resource "aws_internet_gateway" "wordpress" {
  vpc_id = aws_vpc.wordpress.id
  tags   = merge(local.tags, { Name = "wordpress-rds-bonus" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.wordpress.id
  cidr_block              = "10.42.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "wordpress-rds-bonus-public" })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.42.2.0/24"
  availability_zone = "us-east-1b"
  tags              = merge(local.tags, { Name = "wordpress-rds-bonus-private" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wordpress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress.id
  }
  tags = merge(local.tags, { Name = "wordpress-rds-bonus-public" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name_prefix = "wordpress-rds-bonus-web-"
  description = "HTTP for the WordPress bonus host"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description = "HTTP"
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
  tags = merge(local.tags, { Name = "wordpress-rds-bonus-web" })
}

resource "aws_security_group" "database" {
  name_prefix = "wordpress-rds-bonus-db-"
  description = "MySQL only from the WordPress bonus host"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description     = "MySQL from WordPress EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "wordpress-rds-bonus-db" })
}

resource "aws_db_subnet_group" "wordpress" {
  name_prefix = "wordpress-rds-bonus-"
  subnet_ids  = [aws_subnet.public.id, aws_subnet.private.id]
  tags        = merge(local.tags, { Name = "wordpress-rds-bonus" })
}

resource "random_password" "database" {
  length  = 32
  special = false
}

resource "aws_db_instance" "wordpress" {
  identifier_prefix       = "wordpress-rds-bonus-"
  engine                  = "mysql"
  engine_version          = "8.4.11"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "wordpressdb"
  username                = "wpactivity"
  password                = random_password.database.result
  db_subnet_group_name    = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids  = [aws_security_group.database.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  deletion_protection     = false
  tags                    = merge(local.tags, { Name = "wordpress-rds-bonus" })
}

resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = "oliver-kp"
  user_data = templatefile("${path.module}/wp_rds_install.sh.tftpl", {
    db_host     = aws_db_instance.wordpress.address
    db_name     = "wordpressdb"
    db_username = "wpactivity"
    db_password = random_password.database.result
  })
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }
  tags = merge(local.tags, { Name = "wordpress-rds-bonus-web" })
}

output "ec2_public_ip" {
  description = "Open this IP in a browser to view the WordPress installation screen."
  value       = aws_instance.wordpress.public_ip
}

output "wordpress_url" {
  value = "http://${aws_instance.wordpress.public_ip}"
}
