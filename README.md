# vnet-building-block
A Terraform Module to configure a vnet connected to your central hub in your platform tenants. It can be used as a Building Block inside meshStack.

## Prerequisites

- A storage account for terraform state
- A service principal with permissions on the terraform state storage account and permissions to create resource groups and virtual networks
- The central hub vnet

Here is an example terraform file for setting up the storage account, service principal and permissions:

```hcl
locals {
  # Id of the Azure AD tenant that you want to offer your service in.
  tenant_id = "703c8d27-13e0-4836-8b2e-8390c588cf80" # meshcloud-dev

  # Id of the Azure Subscription that should host the service broker container and state.
  subscription_id = "497d294f-0f5d-4641-b448-93b32fcd9e93" # likvid-central-services

  # The scope on which the Service Principal will be granted permissions.
  scope = "/providers/Microsoft.Management/managementGroups/${local.tenant_id}"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  tenant_id       = local.tenant_id
  subscription_id = local.subscription_id
}

resource "azurerm_resource_group" "unipipe_networking" {
  name     = "unipipe-networking"
  location = "West Europe"
}

#
# storage for terraform state of service instances
#
resource "azurerm_storage_account" "unipipe_networking" {
  name                     = "unipipenetworkinglikvid"
  resource_group_name      = azurerm_resource_group.unipipe_networking.name
  location                 = azurerm_resource_group.unipipe_networking.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "unipipe_networking" {
  name                 = "tfstates"
  storage_account_name = azurerm_storage_account.unipipe_networking.name
}

#
# Service Principal for managing service instances
#
resource "azuread_application" "unipipe_networking" {
  display_name = "unipipe-networking"
}

resource "azuread_service_principal" "unipipe_networking" {
  application_id = azuread_application.unipipe_networking.application_id
}

resource "azuread_service_principal_password" "unipipe_networking" {
  service_principal_id = azuread_service_principal.unipipe_networking.object_id
}

#
# Permissions for the Service Principal to manage service instances
#
resource "azurerm_role_definition" "resource_group_contributor" {
  name        = "resource_group_contributor"
  scope       = local.scope
  description = "A custom role that allows to manage resource groups. Used by Cloud Foundation automation."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
    ]
  }

  assignable_scopes = [
    local.scope
  ]
}

resource "azurerm_role_assignment" "resource_group_contributor" {
  scope              = local.scope
  role_definition_id = azurerm_role_definition.resource_group_contributor.role_definition_resource_id
  principal_id       = azuread_service_principal.unipipe_networking.id
}

resource "azurerm_role_assignment" "networking_contributor" {
  scope                = local.scope
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.unipipe_networking.object_id
}

resource "azurerm_role_assignment" "unipipe_networking_backend" {
  scope                = azurerm_storage_account.unipipe_networking.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.unipipe_networking.id
}
```

## How to use this module

1. Fork the repository.
2. Adapt `backend.tf` to use your storage account.
3. Adapt `main.tf` to use your hub vnet.
4. Define the building block in meshSack with the required inputs:
4.1. all required variables that have no default value (check the `variables.tf` file)
4.2. the following environment variables need to be present: ARM_TENANT_ID (AAD tenant of the subscription of the terraform state storage account), ARM_SUBSCRIPTION_ID (subscription of the terraform state storage account), ARM_CLIENT_ID (service principal object id), ARM_CLIENT_SECRET (service principal secret)
