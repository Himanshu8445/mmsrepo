# - Resource Group
variable "resource_groups" {
  description = "Resource groups"
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  default = {}
}

############################
# Application Insights
############################

variable "resource_group_name_ai" {
  type        = string
  description = "The name of the resource group in which the Application Insights is created"
}

variable "application_insights" {
  type = map(object({
    name     = string
  }))
  description = "Map of application insights which needs to be created in a resource group"
  default     = {}
}

variable "law_workspace_id" {
  type        = string
  description = "Specifies the workspace id of log analytics"
}

variable "appin_additional_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

## App Service Plan ##

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