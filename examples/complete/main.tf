module "backend" {
  source = "../.."

  account_id    = var.account_id
  account_alias = var.account_alias
  environment   = var.environment

  name_prefix    = var.name_prefix
  bucket_purpose = "tfstate"

  state_key     = var.state_key
  storage_class = "Standard"

  backup_enabled                  = true
  backup_storage_class            = "InfrequentAccess"
  backup_prefix                   = "snapshots"
  backup_source_suffix            = ".tfstate"
  backup_retention_days           = 90
  enable_backup_lock              = true
  backup_min_lock_days            = 14
  enable_backup_dead_letter_queue = true
}
