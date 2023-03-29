---
severity: Important
pillar: Security
category: Security design principles
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.CORSPolicy/
---

# CORS Policy

## SYNOPSIS

Wildcard * for any configuration option in CORS policies settings should not be used.

## DESCRIPTION

Using wildcard * with CORS policies is overly permissive and may make an API more vulnerable to certain API security threats.

## RECOMMENDATION

Consider configuring the CORS policy and don't use wildcard * for any configuration option. Instead, explicitly list allowed values.

## EXAMPLES

### Configure with Azure template

To deploy API Management CORS policies that pass this rule:

- Configure an policy sub-resource.
- Don't specify wildcard * for any element in `properties.format` property and explicitly list allowed values.

For example an global CORS policy:

```json
{
  "type": "Microsoft.ApiManagement/service/policies",
  "apiVersion": "2021-08-01",
  "name": "[format('{0}/{1}', parameters('name'), 'policy')]",
  "properties": {
    "value": "<policies><inbound><cors allow-credentials="true"><allowed-origins><origin>__APIM__</origin></allowed-origins><allowed-methods preflight-result-max-age="300"><method>GET</method></allowed-methods><allowed-headers><header>x-application</header></allowed-headers><expose-headers><header>x-application-id</header></expose-headers></cors></inbound><backend><forward-request /></backend><outbound /><on-error /></policies>",
    "format": "xml"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]"
  ],
  "metadata": {
    "description": "Configure the API Management Service global policy."
  }
}
```

### Configure with Bicep

To deploy API Management CORS policies that pass this rule:

- Configure an policy sub-resource.
- Don't specify wildcard * for any element in `properties.format` property and explicitly list allowed values.

For example:

```bicep
resource serviceName_policy 'Microsoft.ApiManagement/service/policies@2021-08-01' = {
  parent: service
  name: 'policy'
  properties: {
    value: '<policies><inbound><cors allow-credentials="true"><allowed-origins><origin>__APIM__</origin></allowed-origins><allowed-methods preflight-result-max-age="300"><method>GET</method></allowed-methods><allowed-headers><header>x-application</header></allowed-headers><expose-headers><header>x-application-id</header></expose-headers></cors></inbound><backend><forward-request /></backend><outbound /><on-error /></policies>'
    format: 'xml'
  }
}
```

## NOTES

The rule is only checking against `rawxml` and `xml` policy format content.

## LINKS

- [CORS policy](https://learn.microsoft.com/azure/api-management/cors-policy)
- [Mitigate OWASP API threats](https://learn.microsoft.com/azure/api-management/mitigate-owasp-api-threats#recommendations-6)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)
