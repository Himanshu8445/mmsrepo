variable "resource_group_name_ai" {
  type        = string
  description = "The name of the resource group in which the Application Insights is created"
}

############################
# Application Insights
############################

variable "application_insights" {
  type = map(object({
    name     = string
  }))
  description = "Map of application insights which needs to be created in a resource group"
  default     = {}
}

variable "law_workspace_id" {
  type        = string
  description = "Specifies the workspace id of log analytics"
}

variable "appin_additional_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
