locals {
  tags = var.asp_additional_tags
}

resource "azurerm_service_plan" "asp" {
  for_each                     = var.app_service_plan
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  location                     = each.value.location
  os_type                      = each.value.os_type
  sku_name                     = each.value.sku_name
  per_site_scaling_enabled     = each.value.per_site_scaling_enabled
  maximum_elastic_worker_count = each.value.maximum_elastic_worker_count
  worker_count                 = each.value.worker_count
  zone_balancing_enabled       = each.value.zone_balancing_enabled
  tags                         = local.tags
}