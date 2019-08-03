module "ecs_elb" {
  source = "./lib/elb"

  subnets             = "${var.subnets}"
  ecs_cluster_name    = "${var.ecs_cluster_name}"
  alb_name             = "${var.alb_name}"
  instance_group_name = "${var.instance_group_name}"
  instance_type       = "${var.ecs_instance_type}"
  vpc_id              = "${var.vpc_id}"
  key_name            = "${var.key_name}"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
}

module "ecs" {
  source = "./lib/ecs"

  ecs_cluster_name     = "${var.ecs_cluster_name}"
  ecs_service_name     = "${var.ecs_service_name}"
  elb_target_group_arn = "${module.ecs_elb.alb_target_group_arn}"
}