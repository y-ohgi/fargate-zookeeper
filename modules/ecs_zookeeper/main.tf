data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

locals {
  account_id = "${data.aws_caller_identity.self.account_id}"
  region     = "${data.aws_region.current.name}"
}

#########################
# Task Execution Role
#########################
resource "aws_iam_role" "task_execution" {
  name = "${var.name}-TaskExecution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "task_execution" {
  role = "${aws_iam_role.task_execution.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = "${aws_iam_role.task_execution.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#########################
# Container Definition
#########################
data "template_file" "zoo_servers" {
  count = "${var.number}"

  template = "server.${count.index + 1}=zoo${count.index + 1}.${var.name}.local:2888:3888"
}

locals {
  # Zookeeperのサーバー一覧を台数分動的に生成
  # e.g. server.1=zoo1.sg-stg.local:2888:3888 server.2=zoo2.sg-stg.local:2888:3888 server.3=zoo3.sg-stg.local:2888:3888
  zoo_servers = "${join(" ", data.template_file.zoo_servers.*.rendered)}"
}

data "template_file" "this" {
  count = "${var.number}"

  template = "${file("./container_definitions/zookeeper.json")}"

  vars = {
    name = "${var.name}"

    account_id = "${local.account_id}"
    region     = "${local.region}"
    env        = "${terraform.workspace}"

    zoo_my_id = "${count.index + 1}"

    zoo_servers = "${local.zoo_servers}"
  }
}

#########################
# Task Definition
#########################
resource "aws_ecs_task_definition" "this" {
  count = "${var.number}"

  family = "${var.name}_${count.index + 1}"

  container_definitions = "${element(data.template_file.this.*.rendered, count.index)}"

  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  network_mode             = "${var.task_network_mode}"
  requires_compatibilities = ["${var.task_requires_compatibilities}"]

  task_role_arn      = "${aws_iam_role.task_execution.arn}"
  execution_role_arn = "${aws_iam_role.task_execution.arn}"

  tags = "${map("Name", format("%s", var.name))}"
}

resource "aws_cloudwatch_log_group" "this" {
  count = "${var.number}"

  name              = "/${var.name}/zoo${count.index + 1}"
  retention_in_days = "7"
}

#########################
# Service
#########################
resource "aws_service_discovery_service" "this" {
  count = "${var.number}"

  name = "zoo${count.index + 1}"

  dns_config {
    namespace_id = "${var.service_discovery_namespace_id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_service" "this" {
  count = "${var.number}"

  name = "${var.name}_${count.index + 1}"

  cluster = "${var.ecs_cluster_name}"

  task_definition = "${element(aws_ecs_task_definition.this.*.arn, count.index)}"
  launch_type     = "${var.task_requires_compatibilities}"
  desired_count   = "${var.service_desired_count}"

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    security_groups  = "${var.service_security_groups}"
    subnets          = ["${element(var.subnets, count.index % length(var.subnets))}"]
    assign_public_ip = "true"
  }

  service_registries {
    registry_arn = "${element(aws_service_discovery_service.this.*.arn, count.index)}"
  }
}
