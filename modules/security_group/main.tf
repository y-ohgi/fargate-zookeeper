locals {
  description = "${var.description != "" ? var.description : var.name}"
}

resource "aws_security_group" "this" {
  name        = "${var.name}"
  description = "${local.description}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

#########################
# Ingress Rule
#########################
resource "aws_security_group_rule" "ingress" {
  count = "${length(var.ingress)}"

  type = "ingress"

  security_group_id = "${aws_security_group.this.id}"

  cidr_blocks = "${split(",", lookup(var.ingress[count.index], "cidr_blocks"))}"

  from_port   = "${lookup(var.ingress[count.index], "port")}"
  to_port     = "${lookup(var.ingress[count.index], "port")}"
  protocol    = "tcp"
  description = ""
}

#########################
# Egress Rule
#########################
resource "aws_security_group_rule" "egress" {
  type = "egress"

  security_group_id = "${aws_security_group.this.id}"

  cidr_blocks = ["0.0.0.0/0"]

  from_port = 0
  to_port   = 0
  protocol  = "-1"
}
