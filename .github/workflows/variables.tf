variable "resource_group" {
  type = string
  default = "maydoy-rg" 
}

variable "location" {
  type = string
  default = "East US"
}

variable "vnet_name" {
  type = string
  default = "maydoy-vnet"
}

variable "subnet_name" {
  type = string
  default = "maydoy-subnet"
}

variable "nsg_name" {
  type = string
  default = "maydoy-nsg"
}

variable "public_ip_name" {
  type = string
  default = "maydoy-pip"
}
