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

##Storage Account

variable "storage_accounts" {
  type = map(object({
    name                            = string
    sku                             = string
    resource_group_name             = string
    location                        = string
    account_kind                    = string
    access_tier                     = string
    assign_identity                 = bool
    cmk_enable                      = bool
    min_tls_version                 = string
    is_hns_enabled                  = bool
    large_file_share_enabled        = bool
    public_network_access_enabled   = bool
    allow_nested_items_to_be_public = bool
    network_rules = object({
      bypass                     = list(string) # (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None.
      default_action             = string       # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
      ip_rules                   = list(string) # (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
      virtual_network_subnet_ids = list(string) # (Optional) One or more Subnet ID's which should be able to access this Key Vault.
    })
  }))
  description = "Map of storage accouts which needs to be created in a resource group"
  default     = {}
}

variable "containers" {
  type = map(object({
    name                  = string
    storage_account_name  = string
    container_access_type = string
  }))
  description = "Map of Storage Containers"
  default     = {}
}

variable "sa_additional_tags" {
  type        = map(string)
  description = "Tags of the SA in addition to the resource group tag."
  default = {
    pe_enable = true
  }
}

## Log Analytics

variable "resource_group_name_la" {
  type        = string
  description = "The name of the resource group in which the Log Analytics workspace is created"
}

variable "resource_group_name_str" {
  type        = string
  description = "The name of the resource group in which storage account is created"
}

############################
# log analytics
############################
variable "name" {
  type        = string
  description = "Specifies the name of the Log Analytics Workspace"
}

variable "sku" {
  type        = string
  description = "Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, and PerGB2018"
}

variable "retention_in_days" {
  type        = string
  description = "The workspace data retention in days. Possible values range between 30 and 730"
}

variable "law_additional_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "law_linked_strg_name" {
  type        = string
  description = "Law linked storage account name"
}

## Key Vault

variable "keyvaults" {
  type = map(object({
    keyvault_name                 = string
    location                      = string
    resource_group_name           = string
    kv_sku_name                   = string
    purge_protection              = bool
    public_network_access_enabled = bool
  }))
}

variable "kv_additional_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

#########################
# Key Vault Access Policy
#########################
variable "access_policies" {
  type = map(object({
    group_names             = list(string)
    keyvault_name           = string
    object_id               = string
    user_principal_names    = list(string)
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
  description = "A map of access policies for the Key Vault"
  default     = {}
}

variable "msi_object_id" {
  type        = string
  description = "The object id of the MSI used by the ADO agent"
  default     = null
}

########################
# Key Vault Serets
########################
variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault"
  default     = {}
}