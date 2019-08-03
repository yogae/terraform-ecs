variable "vpc_id" {
    type = string
}

variable "subnets" {
    type = list(string)
}

variable "ecs_cluster_name" {
  type = string
}

variable "instance_group_name" {
  type = string
}

variable "alb_name" {
  type = string
}


variable "ecs_instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ecs_service_name" {
  
}


variable "forbidden_account_ids" {
    type = list(string)
}

variable "allowed_account_ids" {
    type = list(string)
}

variable "aws_access_key" {
    type = string
}

variable "aws_secret_key" {
    type = string
}
