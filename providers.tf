provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# The time provider is used only to rotate the AVD registration key without
# introducing timestamp()-based perpetual diffs.
