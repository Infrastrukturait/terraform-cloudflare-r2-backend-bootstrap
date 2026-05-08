module "bucket" {
  source = "git::https://github.com/rafalmasiarek/terraform-cloudflare-r2-bucket.git?ref=v0.2.0"

  account_id          = var.account_id
  name                = var.name
  location            = var.location
  storage_class       = var.storage_class
  cors                = var.cors
  bucket_lifecycle    = var.bucket_lifecycle
  lock                = var.lock
  sippy               = var.sippy
  managed_domain      = var.managed_domain
  custom_domains      = var.custom_domains
  event_notifications = var.event_notifications
}
