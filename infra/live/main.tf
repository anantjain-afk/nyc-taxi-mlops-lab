# S0: the three hosts share the account's default VPC.  The lab does not create VPCs,
# NAT gateways, IAM roles, or instance profiles: Learner Lab supplies those facilities.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnets" "host_az" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

locals {
  host_subnet_id = one(data.aws_subnets.host_az.ids)
}

module "platform_host" {
  source = "../modules/host"

  role               = "platform"
  instance_type      = var.platform_instance_type
  subnet_id          = local.host_subnet_id
  security_group_ids = [aws_security_group.platform.id]
}

module "app_host" {
  source = "../modules/host"

  role               = "app"
  instance_type      = var.app_instance_type
  subnet_id          = local.host_subnet_id
  security_group_ids = [aws_security_group.app.id]
}

module "llm_host" {
  source = "../modules/host"

  role               = "llm"
  instance_type      = var.llm_instance_type
  subnet_id          = local.host_subnet_id
  security_group_ids = [aws_security_group.llm.id]
}

module "rds" {
  source = "../modules/rds"

  instance_class     = var.rds_instance_class
  subnet_ids         = data.aws_subnets.default_vpc.ids
  security_group_ids = [aws_security_group.rds.id]
}

module "artifact_bucket" {
  source = "../modules/bucket"

  name = "mlops-lab-artifacts"
}

module "wiki_secret" {
  source = "../modules/secret"

  name        = "lab/wiki"
  description = "Wiki URL and token used by the support assistant"
}
