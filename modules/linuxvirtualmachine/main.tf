data "azurerm_resource_group" "this" {
  name = var.resource_group_name_vm
}

/* data "azurerm_log_analytics_workspace" "this" {
  #count               = (var.loganalytics_workspace_name != null && var.enable_log_analytics_extension == true) ? 1 : 0
  name                = var.loganalytics_workspace_name
  resource_group_name = var.loganalytics_resource_group
} */

/* data "azurerm_resources" "this" {
  resource_group_name = var.resource_group_name
} */

/*data "azurerm_storage_account" "custom_storage" {
  name                = var.diagnostics_sa_name
  resource_group_name = var.sa_resource_group_name
}*/

/* data "azurerm_storage_account" "this" {
  name                = var.diagnostics_sa_name
  resource_group_name = var.storage_resource_group
} */

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.Keyvault_resource_group
}

data "azurerm_key_vault" "ssh" {
  for_each            = local.use_existing_ssh_key
  name                = var.ssh_key_vault_name
  resource_group_name = var.ssh_key_vault_rg_name
}

data "azurerm_key_vault_secret" "this" {
  for_each     = local.use_existing_ssh_key
  name         = lookup(each.value, "secret_name_of_public_ssh_key", null)
  key_vault_id = lookup(data.azurerm_key_vault.ssh, each.key)["id"]
}

/* data "azurerm_backup_policy_vm" "this" {
  for_each            = local.linux_vms_for_backup
  name                = each.value.vm_backup_policy_name
  recovery_vault_name = each.value.recovery_services_vault_name
  resource_group_name = var.resource_group_name
} */

data "azurerm_subnet" "this" {
  for_each             = var.linux_vm_nics
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.networking_resource_group
}
# -
# - Get the current user config
# -
data "azurerm_client_config" "current" {}

locals {
  #get list of resources from resource group
  #group_resources            = data.azurerm_resources.this.resources
  tags = var.vm_additional_tags
  #resourcegroup_state_exists = length(values(data.terraform_remote_state.resourcegroup.outputs)) == 0 ? false : true
  #keyvault_state_exists      = length(values(data.terraform_remote_state.keyvault.outputs)) == 0 ? false : true
  des_exists           = { for k, v in var.linux_vms : k => v if lookup(v, "use_existing_disk_encryption_set", false) == true }
  use_existing_ssh_key = { for k, v in var.linux_vms : k => v if lookup(v, "use_existing_ssh_key", false) == true }
  generate_ssh_key     = { for k, v in var.linux_vms : k => v if lookup(v, "use_existing_ssh_key", false) == false }

  key_permissions         = ["Get", "WrapKey", "UnwrapKey"]
  secret_permissions      = ["Get", "Set", "List"]
  certificate_permissions = ["Get", "Create", "Update", "List", "Import"]
  storage_permissions     = ["Get"]
}

#
# Existing DES
#
data "azurerm_disk_encryption_set" "this" {
  for_each            = local.des_exists
  name                = lookup(each.value, "existing_disk_encryption_set_name", null)
  resource_group_name = lookup(each.value, "existing_disk_encryption_set_rg_name", null) == null ? var.resource_group_name_vm : each.value["existing_disk_encryption_set_rg_name"]
}

# -
# - Generate Private/Public SSH Key for Linux Virtual Machine
# -
resource "tls_private_key" "this" {
  for_each  = local.generate_ssh_key
  algorithm = "RSA"
  rsa_bits  = 2048
}

# -
# - Store Generated Private SSH Key to Key Vault Secrets
# -
resource "azurerm_key_vault_secret" "this" {
  for_each     = local.generate_ssh_key
  name         = each.value.name
  value        = lookup(tls_private_key.this, each.key)["private_key_pem"]
  key_vault_id = data.azurerm_key_vault.this.id
}

#
#- Availability Set
#
resource "azurerm_availability_set" "this" {
  for_each                     = var.availability_sets
  name                         = each.value["name"]
  location                     = data.azurerm_resource_group.this.location
  resource_group_name          = var.resource_group_name_vm
  platform_update_domain_count = coalesce(lookup(each.value, "platform_update_domain_count"), 5)
  platform_fault_domain_count  = coalesce(lookup(each.value, "platform_fault_domain_count"), 3)

  tags = local.tags
}

# -
# - Linux Virtual Machine
# -
resource "azurerm_linux_virtual_machine" "linux_vms" {
  for_each            = var.linux_vms
  name                = each.value["name"]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name_vm

  network_interface_ids           = [for nic_k, nic_v in azurerm_network_interface.linux_nics : nic_v.id if(contains(each.value["vm_nic_keys"], nic_k) == true)]
  size                            = coalesce(lookup(each.value, "vm_size"), "Standard_DS1_v2")
  zone                            = lookup(each.value, "availability_set_key", null) == null ? lookup(each.value, "zone", null) : null
  availability_set_id             = lookup(each.value, "availability_set_key", null) == null ? null : lookup(azurerm_availability_set.this, each.value["availability_set_key"])["id"]
  disable_password_authentication = coalesce(lookup(each.value, "disable_password_authentication"), true)
  admin_username                  = var.administrator_user_name
  admin_password                  = coalesce(lookup(each.value, "disable_password_authentication"), true) == false ? var.administrator_login_password : null

  dynamic "admin_ssh_key" {
    for_each = coalesce(lookup(each.value, "disable_password_authentication"), true) == true ? [var.administrator_user_name] : []
    content {
      username   = var.administrator_user_name
      public_key = lookup(each.value, "use_existing_ssh_key", false) == true ? lookup(data.azurerm_key_vault_secret.this, each.key)["value"] : lookup(tls_private_key.this, each.key)["public_key_openssh"]
    }
  }

  os_disk {
    name                      = each.value["os_disk_name"]
    caching                   = coalesce(lookup(each.value, "storage_os_disk_caching"), "ReadWrite")
    storage_account_type      = coalesce(lookup(each.value, "managed_disk_type"), "Standard_LRS")
    disk_size_gb              = lookup(each.value, "disk_size_gb", null)
    write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", null)
    disk_encryption_set_id    = lookup(each.value, "use_existing_disk_encryption_set", false) == true ? lookup(data.azurerm_disk_encryption_set.this, each.key)["id"] : null
  }
  source_image_reference {
    publisher = lookup(each.value, "source_image_reference_publisher", null)
    offer     = lookup(each.value, "source_image_reference_offer", null)
    sku       = lookup(each.value, "source_image_reference_sku", null)
    version   = lookup(each.value, "source_image_reference_version", null)
  }
  additional_capabilities {
    ultra_ssd_enabled = coalesce(each.value.ultra_ssd_enabled, false)
  }

  computer_name = each.value["name"]
  custom_data   = lookup(each.value, "custom_data_path", null) == null ? null : (base64encode(templatefile("${path.root}${each.value["custom_data_path"]}", each.value["custom_data_args"] != null ? each.value["custom_data_args"] : {})))
  #source_image_id = lookup(local.linux_image_ids, each.value["name"], null)

  /* boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.this.primary_blob_endpoint
  } */
  dynamic "identity" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : tolist([coalesce(lookup(each.value, "assign_identity"), false)])
    content {
      type = "SystemAssigned"
    }
  }

  lifecycle {
    ignore_changes = [
      admin_ssh_key,
      network_interface_ids,
      os_disk[0].disk_encryption_set_id
    ]
  }

  tags = local.tags

}

# -
# - Linux Network Interfaces
# -
resource "azurerm_network_interface" "linux_nics" {
  for_each                      = var.linux_vm_nics
  name                          = each.value.name
  location                      = data.azurerm_resource_group.this.location
  resource_group_name           = var.resource_group_name_vm
  internal_dns_name_label       = lookup(each.value, "internal_dns_name_label", null)
  enable_ip_forwarding          = lookup(each.value, "enable_ip_forwarding", null)
  enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", null)
  dns_servers                   = lookup(each.value, "dns_servers", null)

  dynamic "ip_configuration" {
    for_each = coalesce(each.value.nic_ip_configurations, [])
    content {
      name                          = coalesce(ip_configuration.value.name, format("%s00%d-ip", each.value.name, index(each.value.nic_ip_configurations, ip_configuration.value) + 1))
      subnet_id                     = lookup(data.azurerm_subnet.this, each.key)["id"]
      private_ip_address_allocation = lookup(ip_configuration.value, "static_ip", null) == null ? "Dynamic" : "Static"
      private_ip_address            = lookup(ip_configuration.value, "static_ip", null)
      primary                       = index(each.value.nic_ip_configurations, ip_configuration.value) == 0 ? true : false
    }
  }

  tags = local.tags
}
locals {
  linux_vms = {
    for vm_k, vm_v in var.linux_vms :
    vm_k => {
      enable_cmk_disk_encryption = coalesce(vm_v.enable_cmk_disk_encryption, false) && (data.azurerm_key_vault.this.purge_protection_enabled == true)
      zone                       = vm_v.zone
      availability_set_key       = vm_v.availability_set_key
    }
  }
}

# -
# - Managed Disk
# -
resource "azurerm_managed_disk" "this" {
  for_each            = var.managed_data_disks
  name                = lookup(each.value, "disk_name", null) == null ? "${azurerm_linux_virtual_machine.linux_vms[each.value["vm_key"]]["name"]}-datadisk-${each.value["lun"]}" : each.value["disk_name"]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  zone                   = lookup(lookup(local.linux_vms, each.value["vm_key"]), "availability_set_key", null) == null ? (lookup(lookup(local.linux_vms, each.value["vm_key"]), "zone", null) != null ? list(lookup(lookup(local.linux_vms, each.value["vm_key"]), "zone")) : []) : []
  storage_account_type   = coalesce(lookup(each.value, "storage_account_type"), "Standard_LRS")
  disk_encryption_set_id = lookup(lookup(local.linux_vms, each.value["vm_key"]), "use_existing_disk_encryption_set", false) == true ? lookup(data.azurerm_disk_encryption_set.this, each.key)["id"] : lookup(lookup(local.linux_vms, each.value["vm_key"]), "enable_cmk_disk_encryption") == true && ((data.azurerm_key_vault.this.purge_protection_enabled) == true) ? lookup(azurerm_disk_encryption_set.this, each.value["vm_key"])["id"] : null
  disk_size_gb           = coalesce(lookup(each.value, "disk_size"), 1)
  os_type                = coalesce(lookup(each.value, "os_type"), "Linux")
  create_option          = coalesce(lookup(each.value, "create_option"), "Empty")
  source_resource_id     = coalesce(lookup(each.value, "create_option"), "Empty") == "Copy" ? each.value.source_resource_id : null

  tags = local.tags

  lifecycle {
    ignore_changes = [disk_encryption_set_id]
  }

  depends_on = [azurerm_linux_virtual_machine.linux_vms, azurerm_disk_encryption_set.this, azurerm_key_vault_access_policy.this]
}

# -
# - Linux VM - Managed Disk Attachment
# -
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each                  = var.managed_data_disks
  managed_disk_id           = lookup(lookup(azurerm_managed_disk.this, each.key), "id", null)
  virtual_machine_id        = azurerm_linux_virtual_machine.linux_vms[each.value["vm_key"]]["id"]
  lun                       = coalesce(lookup(each.value, "lun"), "10")
  caching                   = coalesce(lookup(each.value, "caching"), "ReadWrite")
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", null)
  depends_on                = [azurerm_managed_disk.this, azurerm_linux_virtual_machine.linux_vms]
}

#####################################################
# Linux VM CMK and Disk Encryption Set
#####################################################
locals {
  cmk_enabled_virtual_machines = {
    for vm_k, vm_v in var.linux_vms :
    vm_k => vm_v if coalesce(lookup(vm_v, "enable_cmk_disk_encryption"), false) == true && (data.azurerm_key_vault.this.purge_protection_enabled == true)
  }
}

# -
# - Generate CMK Key for Linux VM
# -
resource "azurerm_key_vault_key" "this" {
  for_each     = local.cmk_enabled_virtual_machines
  name         = each.value.customer_managed_key_name != null ? each.value.customer_managed_key_name : format("%s00%d-key", each.value.name, index(keys(local.cmk_enabled_virtual_machines), each.key) + 1)
  key_vault_id = data.azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt", "encrypt", "sign",
    "unwrapKey", "verify", "wrapKey"
  ]

}

# -
# - Enable Disk Encryption Set for Linux VM using CMK
# -
resource "azurerm_disk_encryption_set" "this" {
  for_each            = local.cmk_enabled_virtual_machines
  name                = each.value.disk_encryption_set_name != null ? each.value.disk_encryption_set_name : format("%s00%d", each.value.name, index(keys(local.cmk_enabled_virtual_machines), each.key) + 1)
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  key_vault_key_id    = lookup(azurerm_key_vault_key.this, each.key)["id"]

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [key_vault_key_id]
  }

  tags = local.tags
}

/* # -
# - Azure Backup for an Linux Virtual Machine
# -
locals {
  linux_vms_for_backup = {
    for vm_k, vm_v in var.linux_vms :
    vm_k => vm_v if vm_v.recovery_services_vault_name != null
  }
}

resource "azurerm_backup_protected_vm" "this" {
  for_each            = length(values(local.linux_vms_for_backup)) > 0 ? local.linux_vms_for_backup : {}
  resource_group_name = var.resource_group_name
  recovery_vault_name = each.value["recovery_services_vault_name"]
  source_vm_id        = azurerm_linux_virtual_machine.linux_vms[each.key].id
  backup_policy_id    = lookup(data.azurerm_backup_policy_vm.this, each.key)["id"]
  depends_on          = [azurerm_linux_virtual_machine.linux_vms]

  lifecycle {
    prevent_destroy = false
    # ignore_changes = [source_vm_id,
    #                   backup_policy_id]
    # ## these ignore_changes are an alternative approach to the bug where RSV soft-delete causes vm destroy to fail
    # ## this was not chosen because it would mean backup policy cannot be changed via code once deployed
    # ## RSV soft delete is behaving as it should.  The pipeline should fail immediately to alert user
  }
} */

# - Enable Log Analytics Diagnostics and Logs on Azure Linux VM
# -
/* resource "azurerm_virtual_machine_extension" "log_analytics" {
  for_each = var.enable_log_analytics_extension == true ? var.linux_vms : {}
  #for_each             = var.linux_vms
  name                 = "log-analytics"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux_vms[each.key].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.13"
  settings             = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.this.workspace_id}"     
    }
  SETTINGS

  protected_settings = <<SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.this.primary_shared_key}"
    }
  SETTINGS

  tags = data.azurerm_resource_group.this.tags

} */
locals {
  vm_ids_map = {
    for vm in azurerm_linux_virtual_machine.linux_vms :
    vm.name => vm.id
  }

  msi_enabled_linux_vms = [
    for vm_k, vm_v in var.linux_vms :
    vm_v if coalesce(lookup(vm_v, "assign_identity"), false) == true
  ]

  vm_principal_ids = flatten([
    for x in azurerm_linux_virtual_machine.linux_vms :
    [
      for y in x.identity :
      y.principal_id if y.principal_id != ""
    ] if length(keys(azurerm_linux_virtual_machine.linux_vms)) > 0
  ])
}
resource "azurerm_key_vault_access_policy" "this" {
  count        = length(local.msi_enabled_linux_vms)
  key_vault_id = data.azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = element(local.vm_principal_ids, count.index)

  key_permissions         = local.key_permissions
  secret_permissions      = local.secret_permissions
  certificate_permissions = local.certificate_permissions
  storage_permissions     = local.storage_permissions

  depends_on = [azurerm_linux_virtual_machine.linux_vms]
}

resource "azurerm_role_assignment" "kv" {
  count                            = (var.kv_role_assignment == true && length(local.msi_enabled_linux_vms) > 0) ? length(local.vm_principal_ids) : 0
  scope                            = data.azurerm_key_vault.this.id
  role_definition_name             = "Reader"
  principal_id                     = element(local.vm_principal_ids, count.index)
  skip_service_principal_aad_check = true
}
# -
# - Enabling Azure Monitor Dependency virtual machine extension for Azure Linux VM 
# -
/* resource "azurerm_virtual_machine_extension" "vm_insights" {
  for_each = var.enable_vm_insight == true ? var.linux_vms : {}
  #for_each                    = var.linux_vms
  name                       = "vm-insights"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_vms[each.key].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  tags                       = data.azurerm_resource_group.this.tags
  depends_on                 = [azurerm_virtual_machine_extension.log_analytics]
} */

# -
# - Enabling Network Watcher extension on Azure Linux VM 
# -
/* resource "azurerm_virtual_machine_extension" "network_watcher" {
  for_each = var.enable_network_watcher_extension == true ? var.linux_vms : {}
  #for_each                   = var.linux_vms
  name                       = "network-watcher"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_vms[each.key].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  tags                       = data.azurerm_resource_group.this.tags
  depends_on                 = [azurerm_virtual_machine_extension.vm_insights]
}
resource "azurerm_virtual_machine_extension" "AADSSHLoginForLinux" {
  for_each                   = var.linux_vms
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_vms[each.key].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = data.azurerm_resource_group.this.tags
  depends_on                 = [azurerm_virtual_machine_extension.network_watcher]
}
resource "azurerm_virtual_machine_extension" "azure_monitor_linux_agent" {
  for_each                   = var.linux_vms
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux_vms[each.key].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = data.azurerm_resource_group.this.tags
  depends_on                 = [azurerm_virtual_machine_extension.network_watcher]
} */