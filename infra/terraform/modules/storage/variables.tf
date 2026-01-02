variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "subnet_id" {
  type = string
  description = "Subnet ID to place the Private Endpoint"
}

variable "upload_container_name" {
  type = string
  default = "uploads"
}

variable "processed_container_name" {
  type = string
  default = "processed"
}