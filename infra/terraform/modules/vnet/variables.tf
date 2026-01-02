variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "chainlit-demo-vnet"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "private_subnet_name" {
  type    = string
  default = "private-subnet"
}

variable "private_subnet_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}