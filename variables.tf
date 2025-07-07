variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "VPC 1"
}
variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}
variable "us_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "ec2_ami_id" {
  type        = string
  description = " Amazon Linux 2023 instance us-east-1 "
}

variable "public_key" {
  type        = string
  description = "Public key for EC2 instance"
}