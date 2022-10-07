<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-imc-access/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-imc-access/actions/workflows/terratest.yml)
# Terraform Intersight Policies - IMC Access
Manages Intersight IMC Access Policies

Location in GUI:
`Policies` » `Create Policy` » `IMC Access`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Example

### main.tf
```hcl
module "imc_access" {
  source  = "terraform-cisco-modules/policies-imc-access/intersight"
  version = ">= 1.0.1"

  description                = "default IMC Access Policy."
  inband_ip_pool             = "default"
  inband_vlan_id             = 4
  ipv4_address_configuration = true
  ipv6_address_configuration = false
  name                       = "default"
  organization               = "default"
  out_of_band_ip_pool        = ""
}

```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_inband_vlan_id"></a> [inband\_vlan\_id](#input\_inband\_vlan\_id) | VLAN ID to Assign as the Inband Management VLAN for IMC Access. | `number` | `4` | no |
| <a name="input_inband_ip_pool"></a> [inband\_ip\_pool](#input\_inband\_ip\_pool) | Name of the IP Pool to Assign to the IMC Access Policy. | `string` | `""` | no |
| <a name="input_ipv4_address_configuration"></a> [ipv4\_address\_configuration](#input\_ipv4\_address\_configuration) | Flag to Enable or Disable the IPv4 Address Family for Poliices. | `bool` | `true` | no |
| <a name="input_ipv6_address_configuration"></a> [ipv6\_address\_configuration](#input\_ipv6\_address\_configuration) | Flag to Enable or Disable the IPv6 Address Family for Poliices. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_moids"></a> [moids](#input\_moids) | Flag to Determine if pools and policies should be data sources or if they already defined as a moid. | `bool` | `false` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_out_of_band_ip_pool"></a> [out\_of\_band\_ip\_pool](#input\_out\_of\_band\_ip\_pool) | Name of the IP Pool to Assign to the IMC Access Policy. | `string` | `""` | no |
| <a name="input_pools"></a> [pools](#input\_pools) | Map for Moid based Pool Sources. | `any` | `{}` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of Profiles to Assign to the Policy.<br>* name - Name of the Profile to Assign.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - chassis.Profile - For UCS Chassis Profiles.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = optional(string, "server.Profile")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | IMC Access Policy Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_access_policy.imc_access](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/access_policy) | resource |
| [intersight_chassis_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/chassis_profile) | data source |
| [intersight_ippool_pool.ip](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/ippool_pool) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
<!-- END_TF_DOCS -->