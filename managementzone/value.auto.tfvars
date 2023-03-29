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

## Key Vault

keyvaults = {
  "kv_1" = {
    keyvault_name                 = "kvfxlmangzeu2prd001"
    location                      = "East US 2"
    resource_group_name           = "rg-fxl-stgkv-eu2-prd-001"
    kv_sku_name                   = "standard"
    purge_protection              = true
    public_network_access_enabled = true
  }
}

access_policies = {
  "accp1" = {
    keyvault_name           = "kvfxlmangzeu2prd001"
    group_names             = []
    object_id               = "3297d4a1-ef85-40d6-b38b-18ee6ba197f3"
    user_principal_names    = []
    certificate_permissions = ["Get", "List"]
    key_permissions         = ["Get", "List"]
    secret_permissions      = ["Get", "List", "Set"]
    storage_permissions     = ["Backup", "Get", "List", "ListSAS", "Recover", "Restore"]
  }
}

secrets = {}

kv_additional_tags = {
  iac = "Terraform"
}

## Virtual Networks ##

npe_resource_group_name = "rg-fxl-vnet-eu2-npe-001"
npe_location            = "East US 2"
cus_resource_group_name = "rg-fxl-vnet-cus-prd-001"
cus_location            = "centralus"
eus_resource_group_name = "rg-fxl-vnet-eu2-prd-001"
eus_location            = "East US 2"

npe_virtual_networks = {
  npe = {
    name                 = "vnet-fxl-mangz-eu2-npe-001"
    address_space        = ["172.19.160.0/22"]
    dns_servers          = null
    ddos_protection_plan = null
  }
}

cus_virtual_networks = {
  cus = {
    name                 = "vnet-fxl-mangz-cus-prd-001"
    address_space        = ["172.19.164.0/23"]
    dns_servers          = null
    ddos_protection_plan = null
  }
}

eus_virtual_networks = {
  eus = {
    name                 = "vnet-fxl-mangz-eu2-prd-001"
    address_space        = ["172.19.206.0/23"]
    dns_servers          = null
    ddos_protection_plan = null
  }
}

npe_subnets = {
  subnet1 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-admin-eu2-dev-001"
    address_prefixes  = ["172.19.160.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet2 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mlfrw-eu2-dev-001"
    address_prefixes  = ["172.19.162.0/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet3 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mlscr-eu2-dev-001"
    address_prefixes  = ["172.19.162.16/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet4 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mltrn-eu2-dev-001"
    address_prefixes  = ["172.19.162.32/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet5 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-admin-cus-uat-001"
    address_prefixes  = ["172.19.161.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet6 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mlfrw-cus-uat-001"
    address_prefixes  = ["172.19.162.48/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet7 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mlscr-cus-uat-001"
    address_prefixes  = ["172.19.162.64/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet8 = {
    vnet_key          = "npe"
    vnet_name         = "vnet-fxl-mangz-eu2-npe-001"
    name              = "snet-fxl-mltrn-cus-uat-001"
    address_prefixes  = ["172.19.162.80/28"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  }
}

cus_subnets = {
  subnet1 = {
    vnet_key          = "cus"
    vnet_name         = "vnet-fxl-mangz-cus-prd-001"
    name              = "snet-fxl-admin-cus-prd-001"
    address_prefixes  = ["172.19.164.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet2 = {
    vnet_key          = "cus"
    vnet_name         = "vnet-fxl-mangz-cus-prd-001"
    name              = "snet-fxl-mlfrw-cus-prd-001"
    address_prefixes  = ["172.19.165.0/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet3 = {
    vnet_key          = "cus"
    vnet_name         = "vnet-fxl-mangz-cus-prd-001"
    name              = "snet-fxl-mlscr-cus-prd-001"
    address_prefixes  = ["172.19.165.32/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet4 = {
    vnet_key          = "cus"
    vnet_name         = "vnet-fxl-mangz-cus-prd-001"
    name              = "snet-fxl-mltrn-cus-prd-001"
    address_prefixes  = ["172.19.165.64/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  }
}

eus_subnets = {
  subnet1 = {
    vnet_key          = "eus"
    vnet_name         = "vnet-fxl-mangz-eu2-prd-001"
    name              = "snet-fxl-admin-eu2-prd-001"
    address_prefixes  = ["172.19.206.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet2 = {
    vnet_key          = "eus"
    vnet_name         = "vnet-fxl-mangz-eu2-prd-001"
    name              = "snet-fxl-mlfrw-eu2-prd-001"
    address_prefixes  = ["172.19.207.0/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet3 = {
    vnet_key          = "eus"
    vnet_name         = "vnet-fxl-mangz-eu2-prd-001"
    name              = "snet-fxl-mlscr-eu2-prd-001"
    address_prefixes  = ["172.19.207.32/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  },
  subnet4 = {
    vnet_key          = "eus"
    vnet_name         = "vnet-fxl-mangz-eu2-prd-001"
    name              = "snet-fxl-mltrn-eu2-prd-001"
    address_prefixes  = ["172.19.207.64/27"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    pe_enable         = false
    delegation        = null
  }
}

net_additional_tags = {
  iac = "Terraform"
}