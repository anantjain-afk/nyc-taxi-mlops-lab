# S0: these names are frozen by contracts/runtime.yaml.  Scripts and the grader read
# them directly, so keep the output names stable.
output "app_public_ip" {
  value       = module.app_host.public_ip
  description = "Elastic IP of the public Traefik entry point"
}

output "app_instance_id" {
  value       = module.app_host.instance_id
  description = "SSM target and self-hosted runner host for the app"
}

output "platform_instance_id" {
  value       = module.platform_host.instance_id
  description = "SSM target and self-hosted runner host for the platform"
}

output "llm_instance_id" {
  value       = module.llm_host.instance_id
  description = "SSM target and self-hosted runner host for inference"
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "Private RDS endpoint used by Dagster, MLflow and pgvector"
}

output "artifact_bucket" {
  value       = module.artifact_bucket.name
  description = "Private S3 bucket for MLflow artifacts and training data"
}
