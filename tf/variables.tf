variable "aws_region" {
  description = "AWS region where the WordPress EC2 instance is created."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the WordPress host."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name in the selected region."
  type        = string
  default     = "oliver-kp"
}
