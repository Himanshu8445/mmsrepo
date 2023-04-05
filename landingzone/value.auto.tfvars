resource_groups = {
  rg_dev_compute = {
    name     = "rg-fxl-compute-eu2-dev-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  },
  rg_dev_storage = {
    name     = "rg-fxl-storage-eu2-dev-001"
    location = "East US 2"
    tags = {
      iac = "Terraform"
    }
  }
}