provider "azurerm" {
  alias           = "spoke-provider"
  tenant_id       = var.azure_tenant_id
  subscription_id = var.subscription_id
  # client_id and client_secret must be set via env variables
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias           = "hub-provider"
  tenant_id       = var.azure_tenant_id
  subscription_id = var.hub_subscription_id
  # client_id and client_secret must be set via env variables
  features {}
}
