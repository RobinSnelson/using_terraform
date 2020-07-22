variable "subnetID" {
  type        = string
  description = "Subnet ID inside of default virtual network"
}

variable "public_key" {
  type = string
}

variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "subnet_address_prefix" {
  type = string
}