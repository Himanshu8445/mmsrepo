variable "resource_group_name" {
  type        = string
  description = "Specifies the name of the resource group in which to create the Azure Network Base Infrastructure Resources."
}

variable "net_location" {
  type        = string
  description = "Network resources location if different than the resource group's location."
  default     = null
}

variable "location" {
  type        = string
  description = "The Azure Region used for resources such as: key-vault, storage-account, log-analytics and resource group."
}

variable "net_additional_tags" {
  type        = map(string)
  description = "Additional Network resources tags, in addition to the resource group tags."
  default     = {}
}

variable "virtual_networks" {
  description = "The virtal networks with their properties."
  type = map(object({
    name          = string
    address_space = list(string)
    dns_servers   = list(string)
    ddos_protection_plan = object({
      id     = string
      enable = bool
    })
  }))
  default = {}
}

variable "subnets" {
  description = "The virtal networks subnets with their properties."
  type = map(object({
    name              = string
    vnet_key          = string
    vnet_name         = string
    address_prefixes  = list(string)
    pe_enable         = bool
    service_endpoints = list(string)
    delegation = list(object({
      name = string
      service_delegation = list(object({
        name    = string
        actions = list(string)
      }))
    }))
  }))
  default = {}
}