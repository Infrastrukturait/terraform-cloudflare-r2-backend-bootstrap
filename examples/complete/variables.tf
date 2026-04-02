variable "account_id" {
  description = "Cloudflare account ID used to create the R2 backend bucket and optional backup resources."
  type        = string
}

variable "account_alias" {
  description = "Logical account alias used in generated resource names."
  type        = string
  default     = "shared"
}

variable "environment" {
  description = "Environment name used in generated resource names."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Optional prefix added to generated bucket names."
  type        = string
  default     = "platform"
}

variable "state_key" {
  description = "Terraform state object key stored in the backend bucket."
  type        = string
  default     = "bootstrap/terraform.tfstate"
}
