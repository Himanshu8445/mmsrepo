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

## Application Insights ##

resource_group_name_ai = "rg-fxl-compute-eu2-dev-001"

application_insights = {
  application_insights_1  ={
    name = "ai-fxl-eu2-dev-001"
  }
}

law_workspace_id = "/subscriptions/be7051ef-9485-4207-b746-9f6a24b3cc8a/resourceGroups/rg-fxl-infsc-eu2-prd-001/providers/Microsoft.OperationalInsights/workspaces/law-fxl-mangz-cus-prd-001"

appin_additional_tags = {
  iac = "Terraform"
}

## App Service Plan ##

app_service_plan = {
  dev_asp1 = {
    name                         = "aspli-fxl-eu2-dev-001"
    resource_group_name          = "rg-fxl-compute-eu2-dev-001"
    location                     = "East US 2"
    os_type                      = "Linux"
    sku_name                     = "EP1"
    per_site_scaling_enabled     = "false"
    maximum_elastic_worker_count = "2"
    worker_count                 = "2"
    zone_balancing_enabled       = "false"
  }
}

asp_additional_tags = {
  iac             = "Terraform"
}