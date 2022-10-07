terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

# Setup provider, variables and outputs
provider "intersight" {
  apikey    = var.intersight_keyid
  secretkey = file(var.intersight_secretkeyfile)
  endpoint  = var.intersight_endpoint
}

variable "intersight_keyid" {}
variable "intersight_secretkeyfile" {}
variable "intersight_endpoint" {
  default = "intersight.com"
}
variable "name" {}

output "moid" {
  value = module.main.moid
}

# This is the module under test
module "main" {
  source                     = "../.."
  description                = "${var.name} IMC Access Policy."
  inband_ip_pool             = "terratest-inband"
  inband_vlan_id             = 4
  ipv4_address_configuration = true
  ipv6_address_configuration = false
  name                       = var.name
  organization               = "terratest"
  out_of_band_ip_pool        = "terratest-ooband"
}
