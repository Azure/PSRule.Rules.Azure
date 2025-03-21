---
reviewed: 2023-04-29
severity: Important
pillar: Security
category: Design
resource: API Management
resourceType: Microsoft.ApiManagement/service,Microsoft.ApiManagement/service/policies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.CORSPolicy/
---

# Avoid wildcards in APIM CORS policies

## SYNOPSIS

Avoid using wildcard for any configuration option in CORS policies.

## DESCRIPTION

The API Management `cors` policy adds cross-origin resource sharing (CORS) support to an operation or APIs.

CORS is not a security feature.
CORS is a W3C standard that allows a server to relax the same-origin policy enforced by modern browsers.
CORS uses HTTP headers that allows API Management (and other HTTP servers) to indicate any allowed origins.

Using wildcard (`*`) in any policy is overly permissive and may reduce the effectiveness of browser same-origin policy enforcement.

## RECOMMENDATION

Consider configuring the CORS policy by specifying explicit values for each property.

## EXAMPLES

### Configure API Management policy

To deploy API Management CORS policies that pass this rule:

- When configuring `cors` policies provide the exact values for all properties.
- Avoid using wildcards for any property of the `cors` policy including:
  - `allowed-origins`
  - `allowed-methods`
  - `allowed-headers`
  - `expose-headers`

For example a global scoped policy:

```xml
<policies>
  <inbound>
    <cors allow-credentials="true">
      <allowed-origins>
        <origin>https://contoso.developer.azure-api.net</origin>
        <origin>https://developer.contoso.com</origin>
      </allowed-origins>
      <allowed-methods preflight-result-max-age="300">
        <method>GET</method>
        <method>PUT</method>
        <method>POST</method>
        <method>PATCH</method>
        <method>HEAD</method>
        <method>DELETE</method>
        <method>OPTIONS</method>
      </allowed-methods>
      <allowed-headers>
        <header>Content-Type</header>
        <header>Cache-Control</header>
        <header>Authorization</header>
      </allowed-headers>
    </cors>
  </inbound>
  <backend>
    <forward-request />
  </backend>
  <outbound />
  <on-error />
</policies>
```

### Configure with Azure template

To deploy API Management CORS policies that pass this rule:

- Configure an policy sub-resource.
- Avoid using wildcards `*` for any CORS policy element in `properties.value` property.
  Instead provide exact values.

For example a global scoped policy:

```json
{
  "type": "Microsoft.ApiManagement/service/policies",
  "apiVersion": "2022-08-01",
  "name": "[format('{0}/{1}', parameters('name'), 'policy')]",
  "properties": {
    "value": "<policies><inbound><cors allow-credentials=\"true\"><allowed-origins><origin>https://contoso.developer.azure-api.net</origin><origin>https://developer.contoso.com</origin></allowed-origins><allowed-methods preflight-result-max-age=\"300\"><method>GET</method><method>PUT</method><method>POST</method><method>PATCH</method><method>HEAD</method><method>DELETE</method><method>OPTIONS</method></allowed-methods><allowed-headers><header>Content-Type</header><header>Cache-Control</header><header>Authorization</header></allowed-headers></cors></inbound><backend><forward-request /></backend><outbound /><on-error /></policies>",
    "format": "xml"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy API Management CORS policies that pass this rule:

- Configure an policy sub-resource.
- Avoid using wildcards `*` for any CORS policy element in `properties.value` property.
  Instead provide exact values.

For example a global scoped policy:

```bicep
resource globalPolicy 'Microsoft.ApiManagement/service/policies@2022-08-01' = {
  parent: service
  name: 'policy'
  properties: {
    value: '<policies><inbound><cors allow-credentials="true"><allowed-origins><origin>https://contoso.developer.azure-api.net</origin><origin>https://developer.contoso.com</origin></allowed-origins><allowed-methods preflight-result-max-age="300"><method>GET</method><method>PUT</method><method>POST</method><method>PATCH</method><method>HEAD</method><method>DELETE</method><method>OPTIONS</method></allowed-methods><allowed-headers><header>Content-Type</header><header>Cache-Control</header><header>Authorization</header></allowed-headers></cors></inbound><backend><forward-request /></backend><outbound /><on-error /></policies>'
    format: 'xml'
  }
}
```

## NOTES

The rule only checks against `rawxml` and `xml` policy formatted content.

When using Azure Bicep, the policy XML can be loaded from an external file by using the `loadTextContent` function.

## LINKS

- [Application threat analysis](https://learn.microsoft.com/azure/architecture/framework/security/design-threat-model#2--evaluate-the-application-design-progressively)
- [CORS policy](https://learn.microsoft.com/azure/api-management/cors-policy)
- [Mitigate OWASP API threats](https://learn.microsoft.com/azure/api-management/mitigate-owasp-api-threats#recommendations-6)
- [How CORS works](https://learn.microsoft.com/aspnet/core/security/cors?view=aspnetcore-7.0#how-cors)
- [Policies in Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-howto-policies)
- [File functions for Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions-files#loadtextcontent)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)
