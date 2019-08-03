resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecs_instance_profile"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_role" "ecs_instance_role" {
    name = "ecs_instance_role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_instance_policy" { 
    name = "ecs_instance_policy"
    role = "${aws_iam_role.ecs_instance_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecs:StartTask"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_security_group" "instance" {
  name        = "${var.ecs_cluster_name}_${var.instance_group_name}"
  description = "ecs instance sg"
  vpc_id      = "${var.vpc_id}"
}

# We separate the rules from the aws_security_group because then we can manipulate the 
# aws_security_group outside of this module
resource "aws_security_group_rule" "ecs_instance_sg_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.instance.id}"
  source_security_group_id = "${aws_security_group.alb_sg.id}"
}

# We separate the rules from the aws_security_group because then we can manipulate the 
# aws_security_group outside of this module
resource "aws_security_group_rule" "ecs_instance_sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.instance.id}"
}

# Default disk size for Docker is 22 gig, see http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
resource "aws_launch_configuration" "launch" {
  name_prefix          = "${var.ecs_cluster_name}_${var.instance_group_name}"
  image_id             = "${var.aws_ami}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.instance.id}"]
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
EOF
  iam_instance_profile = "${aws_iam_instance_profile.ecs_profile.id}"
  key_name             = "${var.key_name}"

  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created 
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}

# Instances are scaled across availability zones http://docs.aws.amazon.com/autoscaling/latest/userguide/auto-scaling-benefits.html 
resource "aws_autoscaling_group" "asg" {
  name                 = "${var.ecs_cluster_name}_${var.instance_group_name}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.launch.id}"
  vpc_zone_identifier  = "${var.subnets}"
  
  #  load_balancers       = ["${var.load_balancers}"]
  # 인스턴스의 Elastic Load Balancing 상태 확인을 사용하여 트래픽이 정상 인스턴스로만 라우트되는지 확인할 수 있습니다
  target_group_arns    = ["${aws_alb_target_group.default.arn}"]
}

# data "template_file" "user_data" {
#   template = "${file("${path.module}/templates/user_data.sh")}"

#   vars {
#     ecs_config        = "${var.ecs_config}"
#     ecs_logging       = "${var.ecs_logging}"
#     cluster_name      = "${var.cluster}"
#     env_name          = "${var.environment}"
#     custom_userdata   = "${var.custom_userdata}"
#     cloudwatch_prefix = "${var.cloudwatch_prefix}"
#   }
# }