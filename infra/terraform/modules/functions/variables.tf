variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "function_app_name" { type = string }
variable "functions_storage_account_name" { type = string }
variable "package_url" { type = string }
variable "subnet_id" { type = string }
variable "app_settings" { type = map(string) default = {} }