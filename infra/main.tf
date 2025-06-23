module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
}

module "log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  name                = "${var.project_name}-${var.environment}-law"
  location            = var.location
  resource_group_name = module.resource_group.name
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = "PerGB2018"
}
# 