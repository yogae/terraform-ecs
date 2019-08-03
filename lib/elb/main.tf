resource "aws_alb_target_group" "default" {
  name                 = "${var.alb_name}-default"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  # Elastic Load Balancing에서 대상을 등록 취소하기 전에 대기하는 시간
  # deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "/heatlh"
    protocol = "HTTP"
  }
}

resource "aws_alb" "alb" {
  name            = "${var.alb_name}"
  subnets         = "${var.subnets}"
  security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.alb_name}_alb_sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "alb_sg_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_sg.id}"
}

resource "aws_security_group_rule" "alb_sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb_sg.id}"
}

