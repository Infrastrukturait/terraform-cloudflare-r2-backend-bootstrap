locals {
  normalized_name_prefix = var.name_prefix != null && trimspace(var.name_prefix) != "" ? var.name_prefix : null
  normalized_environment = var.environment != null && trimspace(var.environment) != "" ? var.environment : null

  generated_prefix_raw = lower(join("-", compact([
    local.normalized_name_prefix,
    var.account_alias,
    var.bucket_purpose,
    local.normalized_environment,
  ])))

  generated_prefix = trim(replace(local.generated_prefix_raw, "/[^a-z0-9-]/", "-"), "-")

  max_bucket_name_length = 63

  primary_suffix = random_string.bucket_suffix.result

  generated_prefix_max_length = local.max_bucket_name_length - length(local.primary_suffix) - 1

  generated_prefix_safe = (
    length(local.generated_prefix) > local.generated_prefix_max_length
    ? substr(local.generated_prefix, 0, local.generated_prefix_max_length)
    : local.generated_prefix
  )

  generated_bucket_name = (
    length(local.generated_prefix_safe) > 0
    ? "${trim(local.generated_prefix_safe, "-")}-${local.primary_suffix}"
    : local.primary_suffix
  )

  bucket_name = var.bucket_name != null ? var.bucket_name : local.generated_bucket_name

  backup_generated_prefix_raw = lower(join("-", compact([
    local.normalized_name_prefix,
    var.account_alias,
    var.bucket_purpose,
    local.normalized_environment,
    "backup",
  ])))

  backup_generated_prefix = trim(replace(local.backup_generated_prefix_raw, "/[^a-z0-9-]/", "-"), "-")

  backup_suffix = var.backup_enabled && var.backup_bucket_name == null ? random_string.backup_bucket_suffix[0].result : null

  backup_generated_prefix_max_length = local.backup_suffix != null ? local.max_bucket_name_length - length(local.backup_suffix) - 1 : 0

  backup_generated_prefix_safe = local.backup_suffix != null ? (
    length(local.backup_generated_prefix) > local.backup_generated_prefix_max_length
    ? substr(local.backup_generated_prefix, 0, local.backup_generated_prefix_max_length)
    : local.backup_generated_prefix
  ) : null

  backup_generated_bucket_name = var.backup_enabled && var.backup_bucket_name == null ? (
    length(trim(local.backup_generated_prefix_safe, "-")) > 0
    ? "${trim(local.backup_generated_prefix_safe, "-")}-${local.backup_suffix}"
    : local.backup_suffix
  ) : null

  backup_bucket_name = var.backup_enabled ? (
    var.backup_bucket_name != null ? var.backup_bucket_name : local.backup_generated_bucket_name
  ) : null

  backup_location      = var.backup_location != null ? var.backup_location : var.location
  backup_storage_class = var.backup_storage_class != null ? var.backup_storage_class : var.storage_class

  backend_endpoint = "https://${var.account_id}.r2.cloudflarestorage.com"

  backup_prefix_clean      = trimsuffix(trimprefix(trimspace(var.backup_prefix), "/"), "/")
  backup_prefix_for_rules  = local.backup_prefix_clean != "" ? "${local.backup_prefix_clean}/" : ""
  source_prefix_normalized = var.backup_source_prefix != null && trimspace(var.backup_source_prefix) != "" ? trimspace(var.backup_source_prefix) : null
  source_suffix_normalized = var.backup_source_suffix != null && trimspace(var.backup_source_suffix) != "" ? trimspace(var.backup_source_suffix) : null

  primary_bucket_lifecycle = var.enable_bucket_lifecycle ? {
    rules = [
      {
        id      = "abort-stale-multipart-uploads"
        enabled = true

        conditions = {
          prefix = ""
        }

        abort_multipart_uploads_transition = {
          condition = {
            max_age = var.abort_multipart_after_days
            type    = "Age"
          }
        }
      }
    ]
  } : null

  backup_bucket_lifecycle_rules = concat(
    var.enable_backup_bucket_lifecycle ? [
      {
        id      = "abort-stale-multipart-uploads"
        enabled = true

        conditions = {
          prefix = ""
        }

        abort_multipart_uploads_transition = {
          condition = {
            max_age = var.backup_abort_multipart_after_days
            type    = "Age"
          }
        }
      }
    ] : [],
    var.backup_retention_days != null ? [
      {
        id      = "delete-old-backups"
        enabled = true

        conditions = {
          prefix = local.backup_prefix_for_rules
        }

        delete_objects_transition = {
          condition = {
            max_age = var.backup_retention_days
            type    = "Age"
          }
        }
      }
    ] : []
  )

  backup_bucket_lifecycle = var.backup_enabled && length(local.backup_bucket_lifecycle_rules) > 0 ? {
    rules = local.backup_bucket_lifecycle_rules
  } : null

  backup_bucket_lock = var.backup_enabled && var.enable_backup_lock ? {
    rules = [
      {
        id      = "retain-backups-minimum-age"
        enabled = true
        prefix  = local.backup_prefix_for_rules

        condition = {
          max_age_seconds = var.backup_min_lock_days * 86400
          type            = "Age"
        }
      }
    ]
  } : null

  backup_queue_suffix = "backup-queue"
  backup_queue_name = var.backup_queue_name != null ? var.backup_queue_name : (
    length(local.bucket_name) > 63 - length(local.backup_queue_suffix) - 1
    ? "${substr(local.bucket_name, 0, 63 - length(local.backup_queue_suffix) - 1)}-${local.backup_queue_suffix}"
    : "${local.bucket_name}-${local.backup_queue_suffix}"
  )

  backup_dead_letter_queue_suffix = "backup-dlq"
  backup_dead_letter_queue_name = var.backup_dead_letter_queue_name != null ? var.backup_dead_letter_queue_name : (
    length(local.bucket_name) > 63 - length(local.backup_dead_letter_queue_suffix) - 1
    ? "${substr(local.bucket_name, 0, 63 - length(local.backup_dead_letter_queue_suffix) - 1)}-${local.backup_dead_letter_queue_suffix}"
    : "${local.bucket_name}-${local.backup_dead_letter_queue_suffix}"
  )

  backup_worker_suffix = "backup-worker"
  backup_worker_name = var.backup_worker_name != null ? var.backup_worker_name : (
    length(local.bucket_name) > 63 - length(local.backup_worker_suffix) - 1
    ? "${substr(local.bucket_name, 0, 63 - length(local.backup_worker_suffix) - 1)}-${local.backup_worker_suffix}"
    : "${local.bucket_name}-${local.backup_worker_suffix}"
  )

  primary_bucket_event_notifications = var.backup_enabled ? {
    backup = {
      queue_id = cloudflare_queue.backup[0].id
      rules = [
        {
          actions     = ["PutObject", "CopyObject", "CompleteMultipartUpload"]
          description = "Send primary bucket object write events to backup queue"
          prefix      = local.source_prefix_normalized
          suffix      = local.source_suffix_normalized
        }
      ]
    }
  } : {}

  backup_worker_module = <<-EOT
    export default {
      async queue(batch, env) {
        for (const message of batch.messages) {
          try {
            const payload = typeof message.body === "string" ? JSON.parse(message.body) : message.body;

            if (!payload || !payload.object || !payload.object.key) {
              console.warn("Invalid queue payload", payload);
              message.ack();
              continue;
            }

            const sourceKey = payload.object.key;
            const sourceObject = await env.SOURCE_BUCKET.get(sourceKey);

            if (!sourceObject) {
              console.warn("Source object missing, retrying", {
                sourceKey,
                messageId: message.id
              });
              message.retry();
              continue;
            }

            const timestamp = new Date().toISOString()
              .replace(/:/g, "-")
              .replace(/\\./g, "-");

            const backupBasePrefix = env.BACKUP_PREFIX && env.BACKUP_PREFIX.trim() !== ""
              ? env.BACKUP_PREFIX
              : null;

            const backupKey = backupBasePrefix
              ? `$${backupBasePrefix}/$${timestamp}-$${message.id}/$${sourceKey}`
              : `$${timestamp}-$${message.id}/$${sourceKey}`;

            await env.BACKUP_BUCKET.put(backupKey, sourceObject.body, {
              httpMetadata: sourceObject.httpMetadata,
              customMetadata: {
                ...(sourceObject.customMetadata || {}),
                source_bucket: payload.bucket || "",
                source_key: sourceKey,
                source_action: payload.action || "",
                source_event_time: payload.eventTime || "",
                source_etag: payload.object?.eTag || ""
              }
            });

            message.ack();
          } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);

            console.error("Queue message processing failed", {
              messageId: message.id,
              error: errorMessage
            });

            message.retry();
          }
        }
      }
    };
  EOT
}

resource "random_string" "bucket_suffix" {
  length  = var.random_suffix_length
  upper   = false
  special = false
  numeric = var.random_suffix_enable_numeric
  lower   = var.random_suffix_enable_letters
}

resource "random_string" "backup_bucket_suffix" {
  count   = var.backup_enabled && var.backup_bucket_name == null ? 1 : 0
  length  = var.random_suffix_length
  upper   = false
  special = false
  numeric = var.random_suffix_enable_numeric
  lower   = var.random_suffix_enable_letters
}

resource "cloudflare_queue" "backup" {
  count      = var.backup_enabled ? 1 : 0
  account_id = var.account_id
  queue_name = local.backup_queue_name
}

resource "cloudflare_queue" "backup_dead_letter" {
  count      = var.backup_enabled && var.enable_backup_dead_letter_queue ? 1 : 0
  account_id = var.account_id
  queue_name = local.backup_dead_letter_queue_name
}

module "primary_bucket" {
  source = "git::https://github.com/Infrastrukturait/terraform-cloudflare-r2-bucket.git?ref=v0.1.0"

  account_id    = var.account_id
  name          = local.bucket_name
  location      = var.location
  storage_class = var.storage_class

  cors                = null
  bucket_lifecycle    = local.primary_bucket_lifecycle
  lock                = null
  sippy               = null
  managed_domain      = null
  custom_domains      = {}
  event_notifications = local.primary_bucket_event_notifications
}

module "backup_bucket" {
  count  = var.backup_enabled ? 1 : 0
  source = "git::https://github.com/Infrastrukturait/terraform-cloudflare-r2-bucket.git?ref=v0.1.0"

  account_id    = var.account_id
  name          = local.backup_bucket_name
  location      = local.backup_location
  storage_class = local.backup_storage_class

  cors                = null
  bucket_lifecycle    = local.backup_bucket_lifecycle
  lock                = local.backup_bucket_lock
  sippy               = null
  managed_domain      = null
  custom_domains      = {}
  event_notifications = {}
}

resource "cloudflare_worker" "backup_consumer" {
  count      = var.backup_enabled ? 1 : 0
  account_id = var.account_id
  name       = local.backup_worker_name

  observability = {
    enabled = true
  }
}

resource "cloudflare_worker_version" "backup_consumer" {
  count      = var.backup_enabled ? 1 : 0
  account_id = var.account_id
  worker_id  = cloudflare_worker.backup_consumer[0].id

  compatibility_date = var.backup_worker_compatibility_date
  main_module        = "backup-consumer.mjs"

  modules = [
    {
      name           = "backup-consumer.mjs"
      content_type   = "application/javascript+module"
      content_base64 = base64encode(local.backup_worker_module)
    }
  ]

  bindings = [
    {
      type        = "r2_bucket"
      name        = "SOURCE_BUCKET"
      bucket_name = module.primary_bucket.bucket.name
    },
    {
      type        = "r2_bucket"
      name        = "BACKUP_BUCKET"
      bucket_name = module.backup_bucket[0].bucket.name
    },
    {
      type = "plain_text"
      name = "BACKUP_PREFIX"
      text = local.backup_prefix_clean
    }
  ]
}

resource "cloudflare_workers_deployment" "backup_consumer" {
  count       = var.backup_enabled ? 1 : 0
  account_id  = var.account_id
  script_name = cloudflare_worker.backup_consumer[0].name
  strategy    = "percentage"

  versions = [
    {
      percentage = 100
      version_id = cloudflare_worker_version.backup_consumer[0].id
    }
  ]
}

resource "cloudflare_queue_consumer" "backup_worker" {
  count      = var.backup_enabled ? 1 : 0
  account_id = var.account_id
  queue_id   = cloudflare_queue.backup[0].id

  script_name = cloudflare_worker.backup_consumer[0].name
  type        = "worker"

  dead_letter_queue = var.enable_backup_dead_letter_queue ? cloudflare_queue.backup_dead_letter[0].queue_name : null

  settings = {
    batch_size       = var.backup_queue_batch_size
    max_concurrency  = var.backup_queue_max_concurrency
    max_retries      = var.backup_queue_max_retries
    max_wait_time_ms = var.backup_queue_max_wait_time_ms
    retry_delay      = var.backup_queue_retry_delay_seconds
  }

  depends_on = [
    cloudflare_workers_deployment.backup_consumer
  ]
}
