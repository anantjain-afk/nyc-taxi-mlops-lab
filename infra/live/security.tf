# S0: security groups and rules.  Security-group references describe service-to-service
# access; public ingress is confined to the app's Traefik listener.
resource "aws_security_group" "app" {
  name_prefix = "lab-app-"
  description = "App host: public Traefik and egress to lab services"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "platform" {
  name_prefix = "lab-platform-"
  description = "Platform host: MLflow and Dagster reachable through SSM or app"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "llm" {
  name_prefix = "lab-llm-"
  description = "LLM host: chat and embedding APIs for app and platform"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "rds" {
  name_prefix = "lab-rds-"
  description = "RDS: Postgres for app and platform services"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "platform_all" {
  security_group_id = aws_security_group.platform.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "llm_all" {
  security_group_id = aws_security_group.llm.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  for_each = toset(var.ingress_cidrs)

  security_group_id = aws_security_group.app.id
  description       = "Traefik HTTP from the selected ingress scope"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "platform_mlflow_from_app" {
  security_group_id            = aws_security_group.platform.id
  referenced_security_group_id = aws_security_group.app.id
  description                  = "MLflow from app"
  ip_protocol                  = "tcp"
  from_port                    = 5000
  to_port                      = 5000
}

resource "aws_vpc_security_group_ingress_rule" "llm_chat_from_app" {
  security_group_id            = aws_security_group.llm.id
  referenced_security_group_id = aws_security_group.app.id
  description                  = "Chat inference from app"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "llm_embeddings_from_app" {
  security_group_id            = aws_security_group.llm.id
  referenced_security_group_id = aws_security_group.app.id
  description                  = "Embedding inference from app"
  ip_protocol                  = "tcp"
  from_port                    = 8081
  to_port                      = 8081
}

resource "aws_vpc_security_group_ingress_rule" "llm_chat_from_platform" {
  security_group_id            = aws_security_group.llm.id
  referenced_security_group_id = aws_security_group.platform.id
  description                  = "Chat inference from platform"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "llm_embeddings_from_platform" {
  security_group_id            = aws_security_group.llm.id
  referenced_security_group_id = aws_security_group.platform.id
  description                  = "Embedding inference from platform"
  ip_protocol                  = "tcp"
  from_port                    = 8081
  to_port                      = 8081
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.app.id
  description                  = "Postgres from app"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_platform" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.platform.id
  description                  = "Postgres from platform"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
