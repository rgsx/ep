variable "aws_access_key" {
  type        = string
}

variable "aws_secret_key" {
  type        = string
}

variable "aws_key_name" {
  type        = string
  default = "rgsx_key"
}

variable "aws_region" {
  type        = string
    default = "eu-central-1"
}

variable "availability_zone_a" {
  type        = string
  default = "eu-central-1a"
}

variable "availability_zone_b" {
  type        = string
  default = "eu-central-1b"
}

#ubuntu 18.04
variable "instance_ami" {
  type        = string
  default = "ami-0e342d72b12109f91"
}

variable "instance_type" {
  type        = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type        = string
  default = "10.0.0.0/16"
}

variable "cidr_subnet_public_a" {
  type        = string
  default = "10.0.1.0/24"
}

variable "cidr_subnet_public_b" {
  type        = string
  default = "10.0.2.0/24"
}

variable "environment_tag" {
  type        = string
  default = "Production"
}


