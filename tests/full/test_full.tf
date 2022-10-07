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

output "imc" {
  value = module.main.moid
}

output "inband" {
  value = module.inband.moid
}

output "ooband" {
  value = module.ooband.moid
}

module "inband" {
  source  = "terraform-cisco-modules/pools-ip/intersight"
  version = ">=1.0.5"

  assignment_order = "sequential"
  description      = "${var.name} Inband IP Pool"
  ipv4_blocks = [
    {
      from = "198.18.10.10"
      size = 240
    }
  ]
  ipv4_config = [
    {
      gateway       = "198.18.10.1"
      netmask       = "255.255.255.0"
      primary_dns   = "208.67.220.220"
      secondary_dns = "208.67.222.222"
    }
  ]
  name         = "${var.name}-inb"
  organization = "terratest"
}

module "ooband" {
  source  = "terraform-cisco-modules/pools-ip/intersight"
  version = ">=1.0.5"

  assignment_order = "sequential"
  description      = "${var.name} Ooband IP Pool"
  ipv4_blocks = [
    {
      from = "198.18.11.10"
      size = 240
    }
  ]
  ipv4_config = [
    {
      gateway       = "198.18.11.1"
      netmask       = "255.255.255.0"
      primary_dns   = "208.67.220.220"
      secondary_dns = "208.67.222.222"
    }
  ]
  name         = "${var.name}-oob"
  organization = "terratest"
}

# This is the module under test
module "main" {
  depends_on = [
    module.inband,
    module.ooband
  ]
  source                     = "../.."
  description                = "${var.name} IMC Access Policy."
  inband_ip_pool             = module.inband.moid
  inband_vlan_id             = 4
  ipv4_address_configuration = true
  ipv6_address_configuration = false
  moids                      = true
  name                       = var.name
  organization               = "terratest"
  out_of_band_ip_pool        = module.ooband.moid
}
