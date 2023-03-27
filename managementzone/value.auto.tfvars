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