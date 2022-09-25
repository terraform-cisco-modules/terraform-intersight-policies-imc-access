<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - IMC Access
Manages Intersight IMC Access Policies

Location in GUI:
`Policies` » `Create Policy` » `IMC Access`

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
$env:TF_VAR_secretkey="<secret-key-file-location>""
```
<!-- END_TF_DOCS -->