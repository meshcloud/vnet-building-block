#
# Network specific variables
#
variable "location" {
  description = "Location of the network"
  type        = string
}

variable "vnet_prefix" {
  description = "Prefix of the created VNET. It will be used as a base name for the created VNET, Resource Group, etc."
  type        = string
}

variable "vnet_size" {
  description = "Size of the requested vNet"
  type        = string
}

variable "address_space_workload" {
  description = "The address space in CIDR notation for your workload subnets."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.address_space_workload))
    error_message = "address_space_workload must be a valid CIDR range"
  }
}

#
# Azure variables
#

variable "azure_tenant_id" {
  description = "Azure Tenant ID where the managed tenants (subscriptions) as well as the network hub are located in."
  type        = string
}

variable "hub_subscription_id" {
  description = "Subscription ID of the subscription, the network hub is located in."
  type        = string
}

#
# meshStack variables
#

variable "subscription_id" {
  description = "Subscription ID of the subscription the network shall be created in."
  type        = string
}


