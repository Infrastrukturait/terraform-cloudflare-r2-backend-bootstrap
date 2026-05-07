output "bucket_name" {
  description = "Name of the created primary R2 backend bucket."
  value       = module.primary_bucket.bucket.name
}

output "bucket" {
  description = "Created primary R2 bucket details returned by the underlying module."
  value       = module.primary_bucket.bucket
}

output "backup_enabled" {
  description = "Whether the backup stack is enabled."
  value       = var.backup_enabled
}

output "backup_bucket_name" {
  description = "Name of the backup target bucket, if enabled."
  value = var.backup_enabled ? (
    local.backup_uses_separate_bucket ? module.backup_bucket[0].bucket.name : module.primary_bucket.bucket.name
  ) : null
}

output "backup_bucket" {
  description = "Backup target bucket details, if enabled."
  value = var.backup_enabled ? (
    local.backup_uses_separate_bucket ? module.backup_bucket[0].bucket : module.primary_bucket.bucket
  ) : null
}

output "backup_queue_name" {
  description = "Name of the backup queue, if enabled."
  value       = try(cloudflare_queue.backup[0].queue_name, null)
}

output "backup_dead_letter_queue_name" {
  description = "Name of the backup dead letter queue, if enabled."
  value       = try(cloudflare_queue.backup_dead_letter[0].queue_name, null)
}

output "backup_worker_name" {
  description = "Name of the backup Worker, if enabled."
  value       = try(cloudflare_worker.backup_consumer[0].name, null)
}

output "backup_policy" {
  description = "Backup retention and lock settings."
  value = var.backup_enabled ? {
    backup_prefix               = var.backup_prefix
    retention_days              = var.backup_retention_days
    min_lock_days               = var.enable_backup_lock ? var.backup_min_lock_days : null
    source_prefix               = var.backup_source_prefix
    source_suffix               = var.backup_source_suffix
    backup_trigger              = var.backup_trigger
    backup_cron                 = local.backup_uses_cron_trigger ? var.backup_cron : null
    backup_state_key            = local.backup_uses_cron_trigger ? var.backup_state_key : null
    backup_uses_separate_bucket = var.backup_uses_separate_bucket
  } : null
}

output "backend_type" {
  description = "Terraform backend type to use for Cloudflare R2."
  value       = "s3"
}

output "backend_endpoint" {
  description = "S3-compatible R2 endpoint for the Cloudflare account."
  value       = local.backend_endpoint
}

output "backend_config" {
  description = "Suggested backend configuration values for Terraform."
  value = {
    bucket                      = module.primary_bucket.bucket.name
    key                         = var.state_key
    region                      = "auto"
    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    endpoints = {
      s3 = local.backend_endpoint
    }
  }
}

output "backend_config_hcl" {
  description = "Suggested backend configuration rendered as HCL text."
  value = join("\n", [
    "bucket                      = \"${module.primary_bucket.bucket.name}\"",
    "key                         = \"${var.state_key}\"",
    "region                      = \"auto\"",
    "use_path_style              = true",
    "use_lockfile                = true",
    "skip_credentials_validation = true",
    "skip_metadata_api_check     = true",
    "skip_region_validation      = true",
    "skip_requesting_account_id  = true",
    "skip_s3_checksum            = true",
    "endpoints = {",
    "  s3 = \"${local.backend_endpoint}\"",
    "}",
  ])
}

output "backup_summary" {
  description = "Summary of the backup stack."
  value = var.backup_enabled ? {
    primary_bucket              = module.primary_bucket.bucket.name
    backup_bucket               = local.backup_uses_separate_bucket ? module.backup_bucket[0].bucket.name : module.primary_bucket.bucket.name
    backup_uses_separate_bucket = var.backup_uses_separate_bucket
    backup_trigger              = var.backup_trigger
    backup_cron                 = local.backup_uses_cron_trigger ? var.backup_cron : null
    backup_state_key            = local.backup_uses_cron_trigger ? var.backup_state_key : null
    queue                       = local.backup_uses_event_trigger ? cloudflare_queue.backup[0].queue_name : null
    dead_letter_queue           = local.backup_uses_event_trigger && var.enable_backup_dead_letter_queue ? cloudflare_queue.backup_dead_letter[0].queue_name : null
    worker                      = cloudflare_worker.backup_consumer[0].name
    backup_prefix               = var.backup_prefix
    retention_days              = var.backup_retention_days
    min_lock_days               = var.enable_backup_lock ? var.backup_min_lock_days : null
    source_prefix               = var.backup_source_prefix
    source_suffix               = var.backup_source_suffix
    event_actions               = local.backup_uses_event_trigger ? ["PutObject", "CopyObject", "CompleteMultipartUpload"] : null
  } : null
}

output "r2_access_key_id" {
  description = "Generated R2 S3 Access Key ID for the primary backend bucket, if enabled."
  value       = var.create_access_key ? cloudflare_api_token.r2_backend[0].id : null
  sensitive   = true
}

output "r2_secret_access_key" {
  description = "Generated R2 S3 Secret Access Key for the primary backend bucket, if enabled."
  value       = var.create_access_key ? sha256(cloudflare_api_token.r2_backend[0].value) : null
  sensitive   = true
}

output "backend_credentials" {
  description = "Generated R2 backend credentials, if enabled."
  value = var.create_access_key ? {
    access_key_id     = cloudflare_api_token.r2_backend[0].id
    secret_access_key = sha256(cloudflare_api_token.r2_backend[0].value)
  } : null
  sensitive = true
}

output "backend_config_with_credentials" {
  description = "Suggested backend configuration values for Terraform including generated R2 credentials, if enabled."
  value = merge(
    {
      bucket                      = module.primary_bucket.bucket.name
      key                         = var.state_key
      region                      = "auto"
      use_path_style              = true
      use_lockfile                = true
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      skip_region_validation      = true
      skip_requesting_account_id  = true
      skip_s3_checksum            = true
      endpoints = {
        s3 = local.backend_endpoint
      }
    },
    var.create_access_key ? {
      access_key = cloudflare_api_token.r2_backend[0].id
      secret_key = sha256(cloudflare_api_token.r2_backend[0].value)
    } : {}
  )
  sensitive = true
}

output "backend_config_hcl_with_credentials" {
  description = "Suggested backend configuration rendered as HCL text including generated R2 credentials, if enabled."
  value = var.create_access_key ? join("\n", [
    "bucket                      = \"${module.primary_bucket.bucket.name}\"",
    "key                         = \"${var.state_key}\"",
    "region                      = \"auto\"",
    "use_path_style              = true",
    "use_lockfile                = true",
    "skip_credentials_validation = true",
    "skip_metadata_api_check     = true",
    "skip_region_validation      = true",
    "skip_requesting_account_id  = true",
    "skip_s3_checksum            = true",
    "access_key                  = \"${cloudflare_api_token.r2_backend[0].id}\"",
    "secret_key                  = \"${sha256(cloudflare_api_token.r2_backend[0].value)}\"",
    "endpoints = {",
    "  s3 = \"${local.backend_endpoint}\"",
    "}",
  ]) : null
  sensitive = true
}
