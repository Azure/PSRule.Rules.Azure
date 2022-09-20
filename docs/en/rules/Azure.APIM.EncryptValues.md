---
severity: Important
pillar: Security
category: Data protection
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.EncryptValues/
---

# Use encrypted named values

## SYNOPSIS

API Management named values should be encrypted.

## DESCRIPTION

API Management allows configuration properties to be saved as named values.
Named values are a key/ value pairs, which may contain sensitive information.

When named values are marked as secret they are masked by default in the portal.

## RECOMMENDATION

Consider encrypting all API Management named values.

Additionally consider, using Key Vault to store secrets.
Key Vault improves security by tightly controlling access to secrets and improving management controls.

## EXAMPLES

### Configure with Azure template

To set the display name and the description

set properties.displayName	for the resource type "apis". Dispaly name must be 1 to 300 characters long.

set	properties.description resource type "apis". May include HTML formatting tags.

For example:

```json
# marking the named value as secret
  {
    "type": "Microsoft.ApiManagement/service/namedValues",
    "apiVersion": "2021-08-01",
    "name": "apim-contoso-test-001/sampleNameValue",
    "properties": {
      "displayName": "SampleNamedValueId",
      "value": "SecretValue",
      "secret": true # <----------------- marking value as secret  
    }
  }

  # Key vault integration for the named values with user assigned identity
  {
    "type": "Microsoft.ApiManagement/service/namedValues",
    "apiVersion": "2021-08-01",
    "name": "apim-contoso-test-001/sampleNameValue",
    "properties": {
      "displayName": "SampleNamedValueId",
      "keyVault": { # <----------------- value read from the Keyvault
          "identityClientId": "identityClientId", # <----------------- client id of the user assigned identity 
          "secretIdentifier": "SampleNamedValueId"
        },  
    }
  }

  # Key vault integration for the named values with system assigned identity
  {
    "type": "Microsoft.ApiManagement/service/namedValues",
    "apiVersion": "2021-08-01",
    "name": "apim-contoso-test-001/sampleNameValue",
    "properties": {
      "displayName": "SampleNamedValueId",
      "keyVault": { # <----------------- value read from the Keyvault
          "identityClientId": null, # <----------------- null indicates to use the system assigned identity 
          "secretIdentifier": "SampleNamedValueId"
        },  
    }
  }




```

### Configure with Bicep

For example:

```bicep

resource namedValue 'Microsoft.ApiManagement/service/namedValues@2021-12-01-preview' = {
  name: 'apim-contoso-test-001/sampleNameValue'
  parent: service
  properties: {
    displayName: 'SampleNamedValueId'
    secret: true
    value: 'SecretValue'
  }
}


resource namedValue 'Microsoft.ApiManagement/service/namedValues@2021-12-01-preview' = {
  name: 'apim-contoso-test-001/sampleNameValue'
  parent: service
  properties: {
    displayName: 'SampleNamedValueId'
    keyVault: {
      identityClientId: 'identityClientId'
      secretIdentifier: 'SampleNamedValueId'
    }
  }
}

resource namedValue 'Microsoft.ApiManagement/service/namedValues@2021-12-01-preview' = {
  name: 'apim-contoso-test-001/sampleNameValue'
  parent: service
  properties: {
    displayName: 'SampleNamedValueId'
    keyVault: {
      identityClientId: null
      secretIdentifier: 'SampleNamedValueId'
    }
  }
}


```

## LINKS

- [Manage secrets using properties](https://docs.microsoft.com/azure/api-management/api-management-howto-properties)
