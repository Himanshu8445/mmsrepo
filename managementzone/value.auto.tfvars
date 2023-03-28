resource_groups = {
  rg_vnet_npe = {
    name     = "rg-fxl-vnet-eu2-npe-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  },
  rg_vnet_prd = {
    name     = "rg-fxl-vnet-eu2-prd-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  },
  rg_vnet_cus_prd = {
    name     = "rg-fxl-vnet-cus-prd-001"
    location = "Central US"
    tags = {
      iac = "Terraform"
    }
  },
  rg_monitoring = {
    name     = "rg-fxl-infsc-eu2-prd-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  },
  rg_shirvm = {
    name     = "rg-fxl-shirvm-eu2-prd-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  },
  rg_storage = {
    name     = "rg-fxl-stgkv-eu2-prd-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  }
}

## Storage Account

storage_accounts = {
  str_acct_1 = {
    name                            = "stfxlmangzeus2prdbs001"
    sku                             = "Standard_LRS"
    resource_group_name             = "rg-fxl-stgkv-eu2-prd-001"
    location                        = "East US 2"
    account_kind                    = null
    access_tier                     = null
    assign_identity                 = true
    cmk_enable                      = true
    min_tls_version                 = "TLS1_2"
    is_hns_enabled                  = "false"
    large_file_share_enabled        = true
    network_rules                   = null
    public_network_access_enabled   = "true"
    allow_nested_items_to_be_public = "true"
  },
  law_linked_str = {
    name                            = "stfxlmangzeus2prdbs002"
    sku                             = "Standard_LRS"
    resource_group_name             = "rg-fxl-infsc-eu2-prd-001"
    location                        = "East US 2"
    account_kind                    = null
    access_tier                     = null
    assign_identity                 = true
    cmk_enable                      = true
    min_tls_version                 = "TLS1_2"
    is_hns_enabled                  = "false"
    large_file_share_enabled        = true
    network_rules                   = null
    public_network_access_enabled   = "true"
    allow_nested_items_to_be_public = "true"
  }
}

containers = {}

sa_additional_tags = {
  iac = "Terraform"
}

## Log Analytics Workspace

resource_group_name_la  = "rg-fxl-infsc-eu2-prd-001"
resource_group_name_str = "rg-fxl-infsc-eu2-prd-001"
name                    = "law-fxl-mangz-cus-prd-001"
sku                     = "PerGB2018"
retention_in_days       = "60"
law_linked_strg_name    = "stfxlmangzeus2prdbs002"

law_additional_tags = {
  iac = "Terraform"
}