data "azurerm_resource_group" "this" {
  name = var.resource_group_name_ai
}

locals {
  tags = merge(var.appin_additional_tags, data.azurerm_resource_group.this.tags)
}

resource "azurerm_application_insights" "this" {
  for_each            = var.application_insights
  name                = each.value["name"]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  workspace_id        = var.law_workspace_id
  application_type    = "web"
  tags                = local.tags
}