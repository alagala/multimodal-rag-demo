variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "search_service_name" {
  type = string
}

variable "sku" {
  type = string
  default = "basic"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID to place the Private Endpoint"
}