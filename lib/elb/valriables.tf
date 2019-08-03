variable "subnets" {
  type = list(string)
}

variable "alb_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "instance_group_name" {
  type = string
}

variable "aws_ami" {
  type = string
  default = "ami-0accbb5aa909be7bf"
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "key_name" {
  type = string
}

variable "max_size" {
  
}

variable "min_size" {
  
}

variable "desired_capacity" {
  
}