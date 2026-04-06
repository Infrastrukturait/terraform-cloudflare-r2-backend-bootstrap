
# terraform-cloudflare-r2-backend-bootstrap

[![WeSupportUkraine](https://raw.githubusercontent.com/Infrastrukturait/WeSupportUkraine/main/banner.svg)](https://github.com/Infrastrukturait/WeSupportUkraine)
## About
Terraform module to bootstrap a Cloudflare R2 backend for Terraform state, with optional event-driven backup, lifecycle policies, and retention lock.
## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```text
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Source: <https://opensource.org/licenses/MIT>
```
See [LICENSE](LICENSE) for full details.
## Authors
- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)
<!-- BEGIN_TF_DOCS -->
## Documentation


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5.18.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup_bucket"></a> [backup\_bucket](#module\_backup\_bucket) | git::https://github.com/Infrastrukturait/terraform-cloudflare-r2-bucket.git | v0.1.0 |
| <a name="module_primary_bucket"></a> [primary\_bucket](#module\_primary\_bucket) | git::https://github.com/Infrastrukturait/terraform-cloudflare-r2-bucket.git | v0.1.0 |

### Resources

| Name | Type |
|------|------|
| [cloudflare_api_token.r2_backend](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/api_token) | resource |
| [cloudflare_queue.backup](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/queue) | resource |
| [cloudflare_queue.backup_dead_letter](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/queue) | resource |
| [cloudflare_queue_consumer.backup_worker](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/queue_consumer) | resource |
| [cloudflare_worker.backup_consumer](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/worker) | resource |
| [cloudflare_worker_version.backup_consumer](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/worker_version) | resource |
| [cloudflare_workers_deployment.backup_consumer](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/workers_deployment) | resource |
| [random_string.backup_bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_multipart_after_days"></a> [abort\_multipart\_after\_days](#input\_abort\_multipart\_after\_days) | Number of days after which incomplete multipart uploads are aborted on the primary bucket. | `number` | `7` | no |
| <a name="input_access_key_name"></a> [access\_key\_name](#input\_access\_key\_name) | Optional explicit name for the generated R2 API token. | `string` | `null` | no |
| <a name="input_account_alias"></a> [account\_alias](#input\_account\_alias) | Logical account alias used as part of the generated bucket name. | `string` | n/a | yes |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cloudflare account ID used to create the R2 buckets, queue, worker and backend endpoint. | `string` | n/a | yes |
| <a name="input_backup_abort_multipart_after_days"></a> [backup\_abort\_multipart\_after\_days](#input\_backup\_abort\_multipart\_after\_days) | Number of days after which incomplete multipart uploads are aborted on the backup bucket. | `number` | `7` | no |
| <a name="input_backup_bucket_name"></a> [backup\_bucket\_name](#input\_backup\_bucket\_name) | Explicit backup bucket name override. If null and backup\_enabled is true, the module generates a safe random backup bucket name. | `string` | `null` | no |
| <a name="input_backup_dead_letter_queue_name"></a> [backup\_dead\_letter\_queue\_name](#input\_backup\_dead\_letter\_queue\_name) | Explicit dead letter queue name override. | `string` | `null` | no |
| <a name="input_backup_enabled"></a> [backup\_enabled](#input\_backup\_enabled) | When true, create the backup stack: backup bucket, queue, consumer Worker, event notification and optional DLQ. | `bool` | `false` | no |
| <a name="input_backup_location"></a> [backup\_location](#input\_backup\_location) | Optional Cloudflare R2 bucket location for the backup bucket. If null, the primary bucket location is used. | `string` | `null` | no |
| <a name="input_backup_min_lock_days"></a> [backup\_min\_lock\_days](#input\_backup\_min\_lock\_days) | Minimum number of days backup objects must be retained before they can be removed or overwritten. | `number` | `14` | no |
| <a name="input_backup_prefix"></a> [backup\_prefix](#input\_backup\_prefix) | Prefix inside the backup bucket where snapshots are stored. | `string` | `"snapshots"` | no |
| <a name="input_backup_queue_batch_size"></a> [backup\_queue\_batch\_size](#input\_backup\_queue\_batch\_size) | Maximum number of messages delivered per batch to the backup Worker. | `number` | `10` | no |
| <a name="input_backup_queue_max_concurrency"></a> [backup\_queue\_max\_concurrency](#input\_backup\_queue\_max\_concurrency) | Maximum number of concurrent backup Worker consumers. | `number` | `10` | no |
| <a name="input_backup_queue_max_retries"></a> [backup\_queue\_max\_retries](#input\_backup\_queue\_max\_retries) | Maximum number of retries for failed queue messages. | `number` | `5` | no |
| <a name="input_backup_queue_max_wait_time_ms"></a> [backup\_queue\_max\_wait\_time\_ms](#input\_backup\_queue\_max\_wait\_time\_ms) | Maximum time in milliseconds to wait for a queue batch to fill. | `number` | `5000` | no |
| <a name="input_backup_queue_name"></a> [backup\_queue\_name](#input\_backup\_queue\_name) | Explicit backup queue name override. | `string` | `null` | no |
| <a name="input_backup_queue_retry_delay_seconds"></a> [backup\_queue\_retry\_delay\_seconds](#input\_backup\_queue\_retry\_delay\_seconds) | Retry delay in seconds before a failed queue message becomes available again. | `number` | `30` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Delete backup objects older than this many days. Set to null to disable automatic deletion. | `number` | `90` | no |
| <a name="input_backup_source_prefix"></a> [backup\_source\_prefix](#input\_backup\_source\_prefix) | Optional prefix filter for primary bucket event notifications. | `string` | `null` | no |
| <a name="input_backup_source_suffix"></a> [backup\_source\_suffix](#input\_backup\_source\_suffix) | Optional suffix filter for primary bucket event notifications. | `string` | `null` | no |
| <a name="input_backup_storage_class"></a> [backup\_storage\_class](#input\_backup\_storage\_class) | Optional storage class for the backup bucket. If null, the primary bucket storage class is used. | `string` | `null` | no |
| <a name="input_backup_worker_compatibility_date"></a> [backup\_worker\_compatibility\_date](#input\_backup\_worker\_compatibility\_date) | Compatibility date for the backup Worker. | `string` | `"2026-04-02"` | no |
| <a name="input_backup_worker_name"></a> [backup\_worker\_name](#input\_backup\_worker\_name) | Explicit backup Worker name override. | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Explicit primary bucket name override. If null, the module generates a safe random name. | `string` | `null` | no |
| <a name="input_bucket_purpose"></a> [bucket\_purpose](#input\_bucket\_purpose) | Logical bucket purpose used as part of the generated bucket name. | `string` | `"tfstate"` | no |
| <a name="input_create_access_key"></a> [create\_access\_key](#input\_create\_access\_key) | Whether to create bucket-scoped R2 S3 credentials for the primary backend bucket. | `bool` | `false` | no |
| <a name="input_enable_backup_bucket_lifecycle"></a> [enable\_backup\_bucket\_lifecycle](#input\_enable\_backup\_bucket\_lifecycle) | Enable default lifecycle rules on the backup bucket. | `bool` | `true` | no |
| <a name="input_enable_backup_dead_letter_queue"></a> [enable\_backup\_dead\_letter\_queue](#input\_enable\_backup\_dead\_letter\_queue) | Create a dead letter queue for backup processing failures. | `bool` | `true` | no |
| <a name="input_enable_backup_lock"></a> [enable\_backup\_lock](#input\_enable\_backup\_lock) | Enable a minimum retention lock on the backup bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_lifecycle"></a> [enable\_bucket\_lifecycle](#input\_enable\_bucket\_lifecycle) | Enable default lifecycle rules on the primary bucket. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Optional environment name used as part of the generated bucket name. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Optional Cloudflare R2 bucket location for the primary bucket. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional extra prefix added to the generated bucket name. | `string` | `null` | no |
| <a name="input_random_suffix_enable_letters"></a> [random\_suffix\_enable\_letters](#input\_random\_suffix\_enable\_letters) | Enable lowercase letters in the random suffix. | `bool` | `false` | no |
| <a name="input_random_suffix_enable_numeric"></a> [random\_suffix\_enable\_numeric](#input\_random\_suffix\_enable\_numeric) | Enable numeric characters in the random suffix. | `bool` | `true` | no |
| <a name="input_random_suffix_length"></a> [random\_suffix\_length](#input\_random\_suffix\_length) | Length of the random suffix appended to generated bucket names. | `number` | `12` | no |
| <a name="input_state_key"></a> [state\_key](#input\_state\_key) | Suggested Terraform state object key used in backend configuration. | `string` | `"terraform.tfstate"` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Default storage class for newly uploaded objects in the primary bucket. | `string` | `"Standard"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_config"></a> [backend\_config](#output\_backend\_config) | Suggested backend configuration values for Terraform. |
| <a name="output_backend_config_hcl"></a> [backend\_config\_hcl](#output\_backend\_config\_hcl) | Suggested backend configuration rendered as HCL text. |
| <a name="output_backend_config_hcl_with_credentials"></a> [backend\_config\_hcl\_with\_credentials](#output\_backend\_config\_hcl\_with\_credentials) | Suggested backend configuration rendered as HCL text including generated R2 credentials, if enabled. |
| <a name="output_backend_config_with_credentials"></a> [backend\_config\_with\_credentials](#output\_backend\_config\_with\_credentials) | Suggested backend configuration values for Terraform including generated R2 credentials, if enabled. |
| <a name="output_backend_credentials"></a> [backend\_credentials](#output\_backend\_credentials) | Generated R2 backend credentials, if enabled. |
| <a name="output_backend_endpoint"></a> [backend\_endpoint](#output\_backend\_endpoint) | S3-compatible R2 endpoint for the Cloudflare account. |
| <a name="output_backend_type"></a> [backend\_type](#output\_backend\_type) | Terraform backend type to use for Cloudflare R2. |
| <a name="output_backup_bucket"></a> [backup\_bucket](#output\_backup\_bucket) | Created backup R2 bucket details returned by the underlying module, if enabled. |
| <a name="output_backup_bucket_name"></a> [backup\_bucket\_name](#output\_backup\_bucket\_name) | Name of the created backup R2 bucket, if enabled. |
| <a name="output_backup_dead_letter_queue_name"></a> [backup\_dead\_letter\_queue\_name](#output\_backup\_dead\_letter\_queue\_name) | Name of the backup dead letter queue, if enabled. |
| <a name="output_backup_enabled"></a> [backup\_enabled](#output\_backup\_enabled) | Whether the backup stack is enabled. |
| <a name="output_backup_policy"></a> [backup\_policy](#output\_backup\_policy) | Backup retention and lock settings. |
| <a name="output_backup_queue_name"></a> [backup\_queue\_name](#output\_backup\_queue\_name) | Name of the backup queue, if enabled. |
| <a name="output_backup_summary"></a> [backup\_summary](#output\_backup\_summary) | Summary of the backup stack. |
| <a name="output_backup_worker_name"></a> [backup\_worker\_name](#output\_backup\_worker\_name) | Name of the backup Worker, if enabled. |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Created primary R2 bucket details returned by the underlying module. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the created primary R2 backend bucket. |
| <a name="output_r2_access_key_id"></a> [r2\_access\_key\_id](#output\_r2\_access\_key\_id) | Generated R2 S3 Access Key ID for the primary backend bucket, if enabled. |
| <a name="output_r2_secret_access_key"></a> [r2\_secret\_access\_key](#output\_r2\_secret\_access\_key) | Generated R2 S3 Secret Access Key for the primary backend bucket, if enabled. |

### Examples

```hcl
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
```

<!-- END_TF_DOCS -->

<!-- references -->

[repo_link]: https://github.com/Infrastrukturait/terraform-cloudflare-r2-backend-bootstrap
