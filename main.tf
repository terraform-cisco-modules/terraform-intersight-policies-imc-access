#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name = each.value
}

data "intersight_ippool_pool" "ip" {
  for_each = { for v in compact([var.inband_ip_pool, var.out_of_band_ip_pool]) : v => v }
  name     = each.value
}

#____________________________________________________________
#
# Intersight UCS Chassis Profile(s) Data Source
# GUI Location: Profiles > UCS Chassis Profiles > {Name}
#____________________________________________________________

data "intersight_chassis_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "chassis.Profile" }
  name     = each.value.name
}

#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight IMC Access Policy
# GUI Location: Policies > Create Policy > IMC Access
#__________________________________________________________________

resource "intersight_access_policy" "imc_access" {
  depends_on = [
    data.intersight_chassis_profile.profiles,
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description = var.description != "" ? var.description : "${var.name} IMC Access Policy."
  inband_vlan = var.inband_vlan_id
  name        = var.name
  address_type {
    enable_ip_v4 = var.enable_ipv4
    enable_ip_v6 = var.enable_ipv6
    object_type  = "access.AddressType"
  }
  configuration_type {
    configure_inband      = var.inband_ip_pool != "" ? true : false
    configure_out_of_band = var.out_of_band_ip_pool != "" ? true : false
  }
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "inband_ip_pool" {
    for_each = { for k, v in [var.inband_ip_pool] : v => v if length(compact([var.inband_ip_pool])) > 0 }
    content {
      moid        = data.intersight_ippool_pool.ip[var.inband_ip_pool].results[0].moid
      object_type = "ippool.Pool"
    }
  }
  dynamic "out_of_band_ip_pool" {
    for_each = {
      for k, v in [var.out_of_band_ip_pool] : v => v if length(compact([var.out_of_band_ip_pool])) > 0
    }
    content {
      moid        = data.intersight_ippool_pool.ip[var.out_of_band_ip_pool].moid
      object_type = "ippool.Pool"
    }
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("chassis.Profile", profiles.value.object_type)
        ) > 0 ? data.intersight_chassis_profile.profiles[profiles.value.name].results[0
        ].moid : length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
