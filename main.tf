provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "self" {}

module "vpc" {
  source = "./modules/vpc"

  name = "${local.name}"
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${local.name}.local"
  description = "${local.name}"

  vpc = "${module.vpc.vpc_id}"
}

module "ecs" {
  source = "./modules/ecs_cluster"

  name = "${local.name}"
}

##################################################
# zookeeper
##################################################
module "sg_zoo" {
  source = "./modules/security_group"

  vpc_id = "${module.vpc.vpc_id}"

  name = "${local.name}_zoo"

  ingress = [
    {
      cidr_blocks = "0.0.0.0/0"
      port        = 2181
    },
    {
      cidr_blocks = "0.0.0.0/0"
      port        = 2888
    },
    {
      cidr_blocks = "0.0.0.0/0"
      port        = 3888
    },
  ]
}

module "ecs_zookeeper" {
  source = "./modules/ecs_zookeeper"

  number = 3

  name = "${local.name}"

  subnets                 = "${module.vpc.public_subnet_ids[0]}"
  service_security_groups = ["${module.sg_zoo.sg_id}"]

  ecs_cluster_name = "${module.ecs.ecs_cluster_name}"

  service_discovery_namespace_id = "${aws_service_discovery_private_dns_namespace.this.id}"
}
