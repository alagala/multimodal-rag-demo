variable "resource_group_name" {
  type        = string
  description = "Name of the Azure Resource Group"
  default     = "rag-demo-rg"
}

variable "location" {
  type        = string
  description = "Azure location to deploy to"
  default     = "westeurope"
}