terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "resource_group" {
  source  = "Azure/avm-res-azurerm-resourcegroup/azurerm"
  version = "0.1.0"

  name     = "rg-artifact-agent"
  location = var.location
}

module "key_vault" {
  source  = "Azure/avm-res-keyvault/azurerm"
  version = "0.1.0"

  name                = "kv-artifact-agent"
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

module "openai" {
  source  = "Azure/avm-res-cognitiveservices-account/azurerm"
  version = "0.1.0"

  name                = "openai-artifact"
  location            = var.location
  resource_group_name = module.resource_group.name
  kind                = "OpenAI"
  sku_name            = "S0"
  properties = {
    custom_subdomain_name = "artifact-openai"
    capabilities           = []
  }
}

module "log_analytics" {
  source  = "Azure/avm-res-loganalytics-workspace/azurerm"
  version = "0.1.0"

  name                = "log-artifact-agent"
  location            = var.location
  resource_group_name = module.resource_group.name
  sku                 = "PerGB2018"
}

module "containerapp_env" {
  source  = "Azure/avm-res-containerapp-environment/azurerm"
  version = "0.1.0"

  name                       = "env-artifact-agent"
  location                   = var.location
  resource_group_name        = module.resource_group.name
  log_analytics_workspace_id = module.log_analytics.id
}

module "container_app" {
  source  = "Azure/avm-res-containerapp/azurerm"
  version = "0.1.0"

  name                = "artifact-retirement-agent"
  location            = var.location
  resource_group_name = module.resource_group.name
  environment_id      = module.containerapp_env.id
  revision_mode       = "Single"

  containers = [
    {
      name   = "agent"
      image  = var.container_image
      cpu    = 0.5
      memory = "1Gi"
      env = [
        { name = "OPENAI_API_KEY", secretRef = "openai-key" },
        { name = "AZDO_PAT", secretRef = "azdo-pat" },
        { name = "GH_TOKEN", secretRef = "gh-token" }
      ]
    }
  ]

  secrets = [
    { name = "openai-key", value = var.openai_key },
    { name = "azdo-pat", value = var.azdo_pat },
    { name = "gh-token", value = var.gh_token }
  ]

  identity = {
    type = "SystemAssigned"
  }
}