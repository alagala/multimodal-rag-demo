variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "app_service_name" { type = string }
variable "name_prefix" { type = string }
variable "sku_tier" { type = string default = "Standard" }
variable "sku_size" { type = string default = "S1" }
variable "runtime" { type = string default = "PYTHON|3.9" }
variable "app_settings" { type = map(string) default = {} }