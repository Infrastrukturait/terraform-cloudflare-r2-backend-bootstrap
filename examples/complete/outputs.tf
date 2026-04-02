output "bucket_name" {
  description = "Primary R2 bucket name for Terraform state."
  value       = module.backend.bucket_name
}

output "backup_bucket_name" {
  description = "Backup R2 bucket name."
  value       = module.backend.backup_bucket_name
}

output "backend_endpoint" {
  description = "Cloudflare R2 S3-compatible endpoint."
  value       = module.backend.backend_endpoint
}

output "backend_config_hcl" {
  description = "Backend configuration snippet to copy into backend \"s3\"."
  value       = module.backend.backend_config_hcl
}

output "backup_summary" {
  description = "Summary of the enabled backup stack."
  value       = module.backend.backup_summary
}
