output "bucket" {
  description = "R2 bucket object returned by the wrapped module."
  value       = module.bucket.bucket
}

output "bucket_name" {
  description = "R2 bucket name."
  value       = module.bucket.bucket.name
}

output "bucket_id" {
  description = "R2 bucket ID."
  value       = module.bucket.bucket.id
}

output "bucket_location" {
  description = "R2 bucket location."
  value       = try(module.bucket.bucket.location, null)
}

output "bucket_storage_class" {
  description = "R2 bucket storage class."
  value       = try(module.bucket.bucket.storage_class, null)
}
