variable "app_service_plan" {
  description = "App Service Plan"
  type = map(object({
    name                         = string
    resource_group_name          = string
    location                     = string
    os_type                      = string
    sku_name                     = string
    maximum_elastic_worker_count = string
    per_site_scaling_enabled     = string
    worker_count                 = string
    zone_balancing_enabled       = string
  }))
  default = {}
}

variable "asp_additional_tags" {
  type        = map(string)
  description = "Tags of the ASP in addition to the resource group tag."
  default     = {}
}