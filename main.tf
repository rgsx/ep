#-------------Variables----
variable "aws_access_key" {
    default = "AKIAVIP2DKG2B6THEYOB"
}

variable "aws_secret_key" {
    default = "CrMcubHkGI7hQvrDD/GI07Y8KXpadtGGdCrE3QVB"
}

variable "aws_key_name" {
    default = "rgsx_key"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-central-1"
}

variable "availability_zone_a" {
  description = "availability zone to create subnet"
  default = "eu-central-1a"
}

variable "availability_zone_b" {
  description = "availability zone to create subnet"
  default = "eu-central-1b"
}

#ubuntu 18.04
variable "instance_ami" {
    description = "AMI for EC2"
    default = "ami-0e342d72b12109f91"
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "cidr_subnet_public_a" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24"
}

variable "cidr_subnet_public_b" {
    description = "CIDR for the Public Subnet"
    default = "10.0.2.0/24"
}

variable "environment_tag" {
  description = "Environment tag"
  default = "Production"
}

#-------------Provider----

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

#=============VPC======================
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Environment = var.environment_tag
  }
}

#=============Subnet======================
resource "aws_subnet" "subnet_public_a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet_public_a
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone_a
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public_b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.cidr_subnet_public_b
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zone_b
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public_a" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_public_b" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.rtb_public.id
}

#=============security_group======================
resource "aws_security_group" "sg_22_80_icmp" {
  name = "sg_22_80_icmp"
  vpc_id = aws_vpc.vpc.id

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

  ingress {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
    from_port = 0
    to_port = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_security_group" "sg_efs_wordpress" {

  name = "sg_efs_wordpress"
  vpc_id = aws_vpc.vpc.id

  ingress {
    security_groups = [aws_security_group.sg_22_80_icmp.id]
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
  }

  egress {
    security_groups = [aws_security_group.sg_22_80_icmp.id]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  tags = {
    Environment = var.environment_tag
  }
}

#===================EFS=======================
resource "aws_efs_file_system" "efs-wordpress" {
  creation_token = "efs-wordpress"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "false"
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_efs_mount_target" "efs_mt_subnet_a" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id = aws_subnet.subnet_public_a.id
  security_groups = [aws_security_group.sg_efs_wordpress.id]
}

resource "aws_efs_mount_target" "efs_mt_subnet_b" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id = aws_subnet.subnet_public_b.id
  security_groups = [aws_security_group.sg_efs_wordpress.id]
}

#=====================Autoscale group===============================
resource "aws_launch_configuration" "lc-wordpress" {
  name_prefix = "lc_wordpress"
  image_id = var.instance_ami
  instance_type = "t2.micro"
  key_name = "rgsx_key"
  security_groups = [aws_security_group.sg_22_80_icmp.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y nginx nfs-common
    sudo rm -f /var/www/html/*
    ip addr show eth0 | grep -Po 'inet \K[\d.]+' | sudo tee  /var/www/html/index.html
    sudo mkdir /efs-wordpress
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-wordpress.dns_name}:/ /efs-wordpress
  EOF
}

resource "aws_autoscaling_group" "as-wordpress" {
  name = "as-wordpress"
  vpc_zone_identifier = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id]
  launch_configuration = aws_launch_configuration.lc-wordpress.name
  min_size = 2
  max_size = 4
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  tag {
    key = "Name"
    value = "ec2 instance"
    propagate_at_launch = true
  }
 depends_on = [
    aws_efs_mount_target.efs_mt_subnet_a,
    aws_efs_mount_target.efs_mt_subnet_b
  ]
}

#================Application Load Balancer========================
resource "aws_alb" "alb-wordpress" {
  name                = "alb-wordpress"
  security_groups     = [aws_security_group.sg_22_80_icmp.id]
  subnets             = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id]

  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_alb_target_group" "tg-alb" {
  name     = "tg-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb-wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg-alb.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "attach-atg-albtg" {
  autoscaling_group_name = aws_autoscaling_group.as-wordpress.id
  alb_target_group_arn   = aws_alb_target_group.tg-alb.arn
}
