---
severity: Critical
pillar: Security
category: Encryption
resource: IoT Hub
resourceType: Microsoft.Devices/IotHubs
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.IoTHub.MinTLS/
---

# Minimum TLS version

## SYNOPSIS

IoT Hubs should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that IoT Hubs accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy IoT Hubs that pass this rule:

- Set the `properties.minTlsVersion` property to `1.2`.

For example:

```json
{
  "type": "Microsoft.Devices/IotHubs",
  "apiVersion": "2022-04-30-preview",
  "name": "[parameters('iotHubName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "S1",
    "capacity": 1,
  },
  "properties": {
    "minimumTlsVersion": "1.2",
  }
}
```

### Configure with Bicep

To deploy IoT Hubs that pass this rule:

- Set the `properties.minTlsVersion` property to `1.2`.

For example:

```bicep
resource IoTHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    minTlsVersion: '1.2'
  }
}
```

## NOTES

The minimum TLS version feature is currently only supported in these regions:
- East US
- South Central US
- West US 2
- US Gov Arizona
- US Gov Virginia

The `minTlsVersion` property is read-only and cannot be changed once your IoT Hub resource is created.
It is therefore important to properly test and validate that all oT devices and services are compatible with TLS 1.2 and the recommended ciphers in advance.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Transport Layer Security (TLS) support in IoT Hub](https://learn.microsoft.com/azure/iot-hub/iot-hub-tls-support)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.devices/iothubs)
