module "imc_access" {
  source  = "terraform-cisco-modules/policies-imc-access/intersight"
  version = ">= 1.0.1"

  description      = "default IMC Access Policy."
      inband_ip_pool             = ""
      inband_vlan_id             = 4
      ipv4_address_configuration = true
      ipv6_address_configuration = false
  name         = "default"
  organization = "default"
      out_of_band_ip_pool        = "default"
}

