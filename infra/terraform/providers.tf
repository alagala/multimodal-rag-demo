terraform {
  required_version = ">= 1.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features = {}
}

# Backend can be configured (e.g., azurerm, remote state) – placeholder for now
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "tfstate"
#     container_name       = "state"
#     key                  = "chainlit-demo.terraform.tfstate"
#   }
# }