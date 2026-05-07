module "backend" {
  source = "../.."

  account_id    = var.account_id
  account_alias = var.account_alias
  environment   = var.environment

  name_prefix    = var.name_prefix
  bucket_purpose = "tfstate"

  state_key     = var.state_key
  storage_class = "Standard"

  backup_enabled              = true
  backup_uses_separate_bucket = false
  backup_trigger              = "scheduled"

  backup_cron      = "0 */6 * * *"
  backup_state_key = var.state_key
  backup_prefix    = "snapshots"

  backup_retention_days = 90
  enable_backup_lock    = true
  backup_min_lock_days  = 14
}
