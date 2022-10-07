package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-imc-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"apikey":        os.Getenv("IS_KEYID"),
		"secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":          instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	imc := terraform.Output(t, terraformOptions, "imc")
	inband := terraform.Output(t, terraformOptions, "inband")
	ooband := terraform.Output(t, terraformOptions, "ooband")
	assert.NotEmpty(t, imc, "TF module IMC Policy output should not be empty")
	assert.NotEmpty(t, inband, "TF module Inband Pool output should not be empty")
	assert.NotEmpty(t, ooband, "TF module Ooband Pool output should not be empty")

	vars2 := map[string]interface{}{
		"inband": inband,
		"name":   instanceName,
		"ooband": ooband,
	}

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} IMC Access Policy.",

	"AddressType": {
        "ClassId": "access.AddressType",
        "EnableIpV4": true,
        "EnableIpV6": false,
        "ObjectType": "access.AddressType"
	},
	"InbandIpPool": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .inband }}",
        "ObjectType": "ippool.Pool",
        "link": "https://www.intersight.com/api/v1/ippool/Pools/{{ .inband }}"
      },
      "InbandVlan": 4,
      "OutOfBandIpPool": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .ooband }}",
        "ObjectType": "ippool.Pool",
        "link": "https://www.intersight.com/api/v1/ippool/Pools/{{ .ooband }}"
	}
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/access/Policies/%s", imc), expectedJSONTemplate, vars2)
}
