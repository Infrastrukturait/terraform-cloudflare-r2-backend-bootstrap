variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "name" {
  description = "R2 bucket name."
  type        = string
}

variable "location" {
  description = "R2 bucket location."
  type        = string
  default     = null
}

variable "storage_class" {
  description = "R2 bucket storage class."
  type        = string
  default     = null
}

variable "cors" {
  description = "R2 bucket CORS configuration."
  type        = any
  default     = null
}

variable "bucket_lifecycle" {
  description = "R2 bucket lifecycle configuration."
  type        = any
  default     = null
}

variable "lock" {
  description = "R2 bucket lock configuration."
  type        = any
  default     = null
}

variable "sippy" {
  description = "R2 Sippy configuration."
  type        = any
  default     = null
}

variable "managed_domain" {
  description = "R2 managed domain configuration."
  type        = any
  default     = null
}

variable "custom_domains" {
  description = "R2 custom domains configuration."
  type        = any
  default     = {}
}

variable "event_notifications" {
  description = "R2 event notifications configuration."
  type        = any
  default     = {}
}
