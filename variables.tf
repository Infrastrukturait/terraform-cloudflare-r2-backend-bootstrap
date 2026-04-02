variable "account_id" {
  description = "Cloudflare account ID used to create the R2 buckets, queue, worker and backend endpoint."
  type        = string
}

variable "account_alias" {
  description = "Logical account alias used as part of the generated bucket name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.account_alias))
    error_message = "account_alias must contain only letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "Optional environment name used as part of the generated bucket name."
  type        = string
  default     = null

  validation {
    condition     = var.environment == null || can(regex("^[A-Za-z0-9-]+$", var.environment))
    error_message = "environment must be null or contain only letters, digits, and hyphens."
  }
}

variable "bucket_purpose" {
  description = "Logical bucket purpose used as part of the generated bucket name."
  type        = string
  default     = "tfstate"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.bucket_purpose))
    error_message = "bucket_purpose must contain only letters, digits, and hyphens."
  }
}

variable "name_prefix" {
  description = "Optional extra prefix added to the generated bucket name."
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Explicit primary bucket name override. If null, the module generates a safe random name."
  type        = string
  default     = null

  validation {
    condition = var.bucket_name == null || (
      can(regex("^[a-z0-9-]+$", var.bucket_name)) &&
      length(var.bucket_name) > 0 &&
      length(var.bucket_name) <= 63
    )
    error_message = "bucket_name must be 1-63 characters long and contain only lowercase letters, digits, and hyphens."
  }
}

variable "random_suffix_length" {
  description = "Length of the random suffix appended to generated bucket names."
  type        = number
  default     = 12

  validation {
    condition     = var.random_suffix_length >= 4 && var.random_suffix_length <= 16
    error_message = "random_suffix_length must be between 4 and 16."
  }
}

variable "random_suffix_enable_numeric" {
  description = "Enable numeric characters in the random suffix."
  type        = bool
  default     = true
}

variable "random_suffix_enable_letters" {
  description = "Enable lowercase letters in the random suffix."
  type        = bool
  default     = false
}

variable "location" {
  description = "Optional Cloudflare R2 bucket location for the primary bucket."
  type        = string
  default     = null
}

variable "storage_class" {
  description = "Default storage class for newly uploaded objects in the primary bucket."
  type        = string
  default     = "Standard"

  validation {
    condition = contains([
      "Standard",
      "InfrequentAccess"
    ], var.storage_class)
    error_message = "storage_class must be Standard or InfrequentAccess."
  }
}

variable "state_key" {
  description = "Suggested Terraform state object key used in backend configuration."
  type        = string
  default     = "terraform.tfstate"
}

variable "enable_bucket_lifecycle" {
  description = "Enable default lifecycle rules on the primary bucket."
  type        = bool
  default     = true
}

variable "abort_multipart_after_days" {
  description = "Number of days after which incomplete multipart uploads are aborted on the primary bucket."
  type        = number
  default     = 7

  validation {
    condition     = var.abort_multipart_after_days >= 1
    error_message = "abort_multipart_after_days must be greater than or equal to 1."
  }
}

variable "backup_enabled" {
  description = "When true, create the backup stack: backup bucket, queue, consumer Worker, event notification and optional DLQ."
  type        = bool
  default     = false
}

variable "backup_bucket_name" {
  description = "Explicit backup bucket name override. If null and backup_enabled is true, the module generates a safe random backup bucket name."
  type        = string
  default     = null

  validation {
    condition = var.backup_bucket_name == null || (
      can(regex("^[a-z0-9-]+$", var.backup_bucket_name)) &&
      length(var.backup_bucket_name) > 0 &&
      length(var.backup_bucket_name) <= 63
    )
    error_message = "backup_bucket_name must be 1-63 characters long and contain only lowercase letters, digits, and hyphens."
  }
}

variable "backup_location" {
  description = "Optional Cloudflare R2 bucket location for the backup bucket. If null, the primary bucket location is used."
  type        = string
  default     = null
}

variable "backup_storage_class" {
  description = "Optional storage class for the backup bucket. If null, the primary bucket storage class is used."
  type        = string
  default     = null

  validation {
    condition = var.backup_storage_class == null || contains([
      "Standard",
      "InfrequentAccess"
    ], var.backup_storage_class)
    error_message = "backup_storage_class must be null, Standard or InfrequentAccess."
  }
}

variable "enable_backup_bucket_lifecycle" {
  description = "Enable default lifecycle rules on the backup bucket."
  type        = bool
  default     = true
}

variable "backup_abort_multipart_after_days" {
  description = "Number of days after which incomplete multipart uploads are aborted on the backup bucket."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_abort_multipart_after_days >= 1
    error_message = "backup_abort_multipart_after_days must be greater than or equal to 1."
  }
}

variable "backup_retention_days" {
  description = "Delete backup objects older than this many days. Set to null to disable automatic deletion."
  type        = number
  default     = 90

  validation {
    condition     = var.backup_retention_days == null || var.backup_retention_days >= 1
    error_message = "backup_retention_days must be null or greater than or equal to 1."
  }
}

variable "enable_backup_lock" {
  description = "Enable a minimum retention lock on the backup bucket."
  type        = bool
  default     = true
}

variable "backup_min_lock_days" {
  description = "Minimum number of days backup objects must be retained before they can be removed or overwritten."
  type        = number
  default     = 14

  validation {
    condition     = var.backup_min_lock_days >= 1
    error_message = "backup_min_lock_days must be at least 1."
  }
}

variable "backup_prefix" {
  description = "Prefix inside the backup bucket where snapshots are stored."
  type        = string
  default     = "snapshots"

  validation {
    condition     = trimspace(var.backup_prefix) != ""
    error_message = "backup_prefix must not be empty."
  }
}

variable "backup_source_prefix" {
  description = "Optional prefix filter for primary bucket event notifications."
  type        = string
  default     = null
}

variable "backup_source_suffix" {
  description = "Optional suffix filter for primary bucket event notifications."
  type        = string
  default     = null
}

variable "backup_queue_name" {
  description = "Explicit backup queue name override."
  type        = string
  default     = null

  validation {
    condition = var.backup_queue_name == null || (
      length(trimspace(var.backup_queue_name)) > 0 &&
      length(var.backup_queue_name) <= 63 &&
      can(regex("^[A-Za-z0-9-_]+$", var.backup_queue_name))
    )
    error_message = "backup_queue_name must be null or 1-63 characters long and contain only letters, digits, hyphens, and underscores."
  }
}

variable "enable_backup_dead_letter_queue" {
  description = "Create a dead letter queue for backup processing failures."
  type        = bool
  default     = true
}

variable "backup_dead_letter_queue_name" {
  description = "Explicit dead letter queue name override."
  type        = string
  default     = null

  validation {
    condition = var.backup_dead_letter_queue_name == null || (
      length(trimspace(var.backup_dead_letter_queue_name)) > 0 &&
      length(var.backup_dead_letter_queue_name) <= 63 &&
      can(regex("^[A-Za-z0-9-_]+$", var.backup_dead_letter_queue_name))
    )
    error_message = "backup_dead_letter_queue_name must be null or 1-63 characters long and contain only letters, digits, hyphens, and underscores."
  }
}

variable "backup_worker_name" {
  description = "Explicit backup Worker name override."
  type        = string
  default     = null

  validation {
    condition = var.backup_worker_name == null || (
      length(trimspace(var.backup_worker_name)) > 0 &&
      length(var.backup_worker_name) <= 63 &&
      can(regex("^[A-Za-z0-9-_]+$", var.backup_worker_name))
    )
    error_message = "backup_worker_name must be null or 1-63 characters long and contain only letters, digits, hyphens, and underscores."
  }
}

variable "backup_worker_compatibility_date" {
  description = "Compatibility date for the backup Worker."
  type        = string
  default     = "2026-04-02"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.backup_worker_compatibility_date))
    error_message = "backup_worker_compatibility_date must be in YYYY-MM-DD format."
  }
}

variable "backup_queue_batch_size" {
  description = "Maximum number of messages delivered per batch to the backup Worker."
  type        = number
  default     = 10

  validation {
    condition     = var.backup_queue_batch_size >= 1 && var.backup_queue_batch_size <= 100
    error_message = "backup_queue_batch_size must be between 1 and 100."
  }
}

variable "backup_queue_max_concurrency" {
  description = "Maximum number of concurrent backup Worker consumers."
  type        = number
  default     = 10

  validation {
    condition     = var.backup_queue_max_concurrency >= 1
    error_message = "backup_queue_max_concurrency must be greater than or equal to 1."
  }
}

variable "backup_queue_max_retries" {
  description = "Maximum number of retries for failed queue messages."
  type        = number
  default     = 5

  validation {
    condition     = var.backup_queue_max_retries >= 0
    error_message = "backup_queue_max_retries must be greater than or equal to 0."
  }
}

variable "backup_queue_max_wait_time_ms" {
  description = "Maximum time in milliseconds to wait for a queue batch to fill."
  type        = number
  default     = 5000

  validation {
    condition     = var.backup_queue_max_wait_time_ms >= 0
    error_message = "backup_queue_max_wait_time_ms must be greater than or equal to 0."
  }
}

variable "backup_queue_retry_delay_seconds" {
  description = "Retry delay in seconds before a failed queue message becomes available again."
  type        = number
  default     = 30

  validation {
    condition     = var.backup_queue_retry_delay_seconds >= 0
    error_message = "backup_queue_retry_delay_seconds must be greater than or equal to 0."
  }
}

variable "backup_queue_visibility_timeout_ms" {
  description = "Visibility timeout in milliseconds for leased queue messages."
  type        = number
  default     = 300000

  validation {
    condition     = var.backup_queue_visibility_timeout_ms >= 1000
    error_message = "backup_queue_visibility_timeout_ms must be greater than or equal to 1000."
  }
}
