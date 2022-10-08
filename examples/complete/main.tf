data "intersight_organization_organization" "org_moid" {
  name = "terratest"
}

module "inband" {
  source  = "terraform-cisco-modules/pools-ip/intersight"
  version = ">=1.0.5"

  assignment_order = "sequential"
  description      = "default Inband IP Pool"
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
  name         = "default-inb"
  organization = "terratest"
}

module "imc_access" {
  source  = "terraform-cisco-modules/policies-imc-access/intersight"
  version = ">= 1.0.1"

  description                = "default IMC Access Policy."
  inband_ip_pool             = "default-inb"
  inband_vlan_id             = 4
  ipv4_address_configuration = true
  ipv6_address_configuration = false
  moids                      = true
  name                       = "default"
  organization               = data.intersight_organization_organization.org_moid.results[0].moid
  out_of_band_ip_pool        = ""
  pools = {
    ip = {
      "default-inb" = {
        moid = module.inband.moid
      }
    }
  }
}

