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

resource "aws_security_group" "wordpress" {
  name_prefix = "github-actions-wordpress-"
  description = "Allow public HTTP to the WordPress demo host"

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

  tags = {
    Name       = "github-actions-wordpress"
    ManagedBy  = "Terraform"
    Assignment = "github-actions-wordpress"
  }
}

resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.wordpress.id]
  user_data                   = file("${path.module}/wp_install.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
  }

  tags = {
    Name       = "github-actions-wordpress"
    ManagedBy  = "Terraform"
    Assignment = "github-actions-wordpress"
  }
}
