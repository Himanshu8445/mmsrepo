module "resourcegroup" {
  source          = "../modules/resourcegroup"
  resource_groups = var.resource_groups
}

module "appliacation-insights" {
  source                 = "../modules/applicationinsights"
  resource_group_name_ai = var.resource_group_name_ai
  application_insights   = var.application_insights
  law_workspace_id       = var.law_workspace_id
  appin_additional_tags  = var.appin_additional_tags
}

module "asp" {
  source              = "../modules/appserviceplan"
  app_service_plan    = var.app_service_plan
  asp_additional_tags = var.asp_additional_tags
}
