module "resourcegroup" {
  source          = "../modules/resourcegroup"
  resource_groups = var.resource_groups
}

module "storage_acct" {
  source             = "../modules/storageaccount"
  storage_accounts   = var.storage_accounts
  containers         = var.containers
  sa_additional_tags = var.sa_additional_tags
  depends_on         = [module.resourcegroup]
}

module "loganalytics" {
  source                  = "../modules/loganalytics"
  resource_group_name_la  = var.resource_group_name_la
  resource_group_name_str = var.resource_group_name_str
  name                    = var.name
  sku                     = var.sku
  retention_in_days       = var.retention_in_days
  law_additional_tags     = var.law_additional_tags
  law_linked_strg_name    = var.law_linked_strg_name
  depends_on = [
    module.storage_acct
  ]
}

module "key-vault" {
  source             = "../modules/keyvault"
  keyvaults          = var.keyvaults
  kv_additional_tags = var.kv_additional_tags
  access_policies    = var.access_policies
  secrets            = var.secrets
  depends_on         = [module.resourcegroup]
}

module "npe-vnet" {
  source                         = "../modules/networking"
  resource_group_name            = var.npe_resource_group_name
  location                       = var.npe_location
  subnets                        = var.npe_subnets
  virtual_networks               = var.npe_virtual_networks
  net_additional_tags            = var.net_additional_tags
}

module "cus-vnet" {
  source                         = "../modules/networking"
  resource_group_name            = var.cus_resource_group_name
  location                       = var.cus_location
  subnets                        = var.cus_subnets
  virtual_networks               = var.cus_virtual_networks
  net_additional_tags            = var.net_additional_tags
}

module "eus-vnet" {
  source                         = "../modules/networking"
  resource_group_name            = var.eus_resource_group_name
  location                       = var.eus_location
  subnets                        = var.eus_subnets
  virtual_networks               = var.eus_virtual_networks
  net_additional_tags            = var.net_additional_tags
}

module "windows-vm" {
  source                      = "../modules/windowsvirtualmachine"
  windows_vms                 = var.windows_vms
  resource_group_name_vm      = var.resource_group_name_vm
  key_vault_name              = var.key_vault_name
  win_administrator_user_name = var.win_administrator_user_name
  windows_vm_nics             = var.windows_vm_nics
  managed_data_disks          = var.managed_data_disks
  key_vault_id                = var.key_vault_id
  Keyvault_resource_group     = var.Keyvault_resource_group
  vm_additional_tags          = var.vm_additional_tags
}