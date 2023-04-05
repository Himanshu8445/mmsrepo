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

law_workspace_id = "/subscriptions/be7051ef-9485-4207-b746-9f6a24b3cc8a/resourceGroups/rg-fxl-infsc-eu2-prd-001/providers/microsoft.operationalinsights/workspaces/law-fxl-mangz-cus-prd-001"

appin_additional_tags = {
  iac = "Terraform"
}