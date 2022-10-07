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
  apikey    = var.apikey
  secretkey = file(var.secretkeyfile)
  endpoint  = var.endpoint
}

variable "apikey" {
  sensitive = true
}

variable "endpoint" {
  default = "intersight.com"
}

variable "name" {}

variable "secretkeyfile" {
  sensitive = true
}

output "imc" {
  value = module.main.moid
}

output "inband" {
  value = module.inband.moid
}

output "ooband" {
  value = module.ooband.moid
}

data "intersight_organization_organization" "org_moid" {
  name = "terratest"
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
  source                     = "../.."
  description                = "${var.name} IMC Access Policy."
  inband_ip_pool             = "${var.name}-inb"
  inband_vlan_id             = 4
  ipv4_address_configuration = true
  ipv6_address_configuration = false
  moids                      = true
  name                       = var.name
  organization               = data.intersight_organization_organization.org_moid.results[0].moid
  out_of_band_ip_pool        = "${var.name}-oob"
  pools = {
    ip = {
      "${var.name}-inb" = {
        moid = module.inband.moid
      }
      "${var.name}-oob" = {
        moid = module.ooband.moid
      }
    }
  }
}
