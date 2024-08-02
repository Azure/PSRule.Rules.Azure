---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.NAT/
---

# Outbound access

## SYNOPSIS

Use Azure NAT gateway for outbound access for virtual machines.

## DESCRIPTION

By default, virtual machines (VMs) created in a virtual network without explicit outbound connectivity are assigned a default outbound public IP address. This IP address enables outbound connectivity to the internet.

Default Routing Behavior:
The subnet has a system default route that routes traffic with the destination 0.0.0.0/0 to the internet.
Normally, when this route is chosen, the traffic is NATed using either a default public IP address or the VM’s public IP address (if it exists) before being sent to the internet.

Behavior with NAT Gateway:
Once a NAT gateway is associated with the subnet, the behavior changes. Although the system default route will still have the next hop set to the internet, traffic is first sent to the NAT gateway.
The NAT gateway receives the traffic from the VMs in the subnet, NATs the traffic using its own public IP address, and then sends it to the internet.

Why use a Azure NAT gateway?

- Enhanced Security
  - Zero Trust Principles: The NAT gateway adheres to the zero trust security model, reducing the attack surface by not exposing your VMs directly to the internet. It ensures that outbound connections are initiated securely without inbound ports being open.
	- Managed Outbound Connections: By centralizing outbound connections through a NAT gateway, you reduce the complexity of managing individual public IPs and security rules on each VM.
- Consistent and Predictable IP Management
	- Static Public IP: The NAT gateway provides a static public IP or range of IPs for all outbound traffic from the subnet, ensuring a consistent and predictable external IP address. This is crucial for scenarios that require whitelisting of IP addresses or need a fixed IP for licensing or compliance purposes.
	-	Ownership and Stability: Unlike default outbound IPs managed by Microsoft, the IPs associated with a NAT gateway are under your control and remain stable, avoiding potential disruptions caused by IP changes.
- Scalability and High Availability
	- Automatic Scaling: NAT gateways are designed to handle large amounts of traffic and automatically scale to meet the demand, providing high throughput and performance without manual intervention.
	- Redundancy: Azure NAT gateway is a fully managed service with built-in redundancy, ensuring high availability and reliability for outbound connections.
- Simplified Network Management
	- Centralized Management: By using a NAT gateway, you centralize the management of outbound connections, simplifying the configuration and maintenance of network security rules and routes.
	- Reduced Complexity: It eliminates the need to manage multiple public IPs or configure individual instance-level public IPs for each VM, reducing administrative overhead and potential configuration errors.
- Cost Efficiency
	- Optimized Resource Usage: NAT gateway helps in optimizing the use of public IP addresses by sharing a single or a few public IPs among multiple VMs in a subnet, potentially reducing the cost associated with public IP addresses.
	- Simplified Billing: With NAT gateway, you only pay for the NAT gateway itself and the data processed, leading to more predictable billing compared to managing multiple public IP addresses.
- Compliance and Auditing
	- Regulatory Compliance: For organizations subject to regulatory compliance, using a NAT gateway provides a controlled and auditable outbound connection point, ensuring compliance with policies that require fixed or known IP addresses.
	- Logging and Monitoring: Azure provides extensive logging and monitoring capabilities for NAT gateways, allowing you to track outbound traffic, monitor for anomalies, and generate audit reports as needed.
 
NAT gateway takes precedence over other outbound connectivity methods, including a load balancer, instance-level public IP addresses, and Azure Firewall.

It is also worth noting that NAT gateway can be used for other Azure services as well.

Note that there are limitations to this feature, so please refer to the documentation for detailed information.

## RECOMMENDATION

Consider using a NAT gateway as the explicit method of public connectivity for virtual machines to ensure security, explicit connectivity, and stability.

## EXAMPLES

### Configure with Azure template

For each subnet object in defined the `properties.subnets` property:
  - Set the `properties.natGateway.id` property to the NAT gateway’s resource ID.

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2023-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "subnets": [
      {
        "name": "subnet-A",
        "properties": {
          "addressPrefix": "10.0.0.0/27",
           "defaultOutboundAccess": false,
           "natGateway": {
            "id": "[parameters('natGatewayResourceId')]",
          }
        }
      },
      {
        "name": "subnet-B",
        "properties": {
          "addressPrefix": "10.0.0.32/27",
          "defaultOutboundAccess": false,
          "natGateway": {
            "id": "[parameters('natGatewayResourceId')]",
          }
        }
      }
    ]
  }
}
```

### Configure with Bicep

To configure virtual networks that pass this rule:

For each subnet object in defined the `properties.subnets` property:
  - Set the `properties.natGateway.id` property to the NAT gateway’s resource ID.

For example:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-A'
        properties: {
          addressPrefix: '10.0.0.0/27'
          defaultOutboundAccess: false
          natGateway: {
            id: natGatewayResourceId
          }
        }
      }
      {
        name: 'subnet-B'
        properties: {
          addressPrefix: '10.0.0.32/27'
          defaultOutboundAccess: false
           natGateway: {
            id: natGatewayResourceId
          }
        }
      }
    ]
  }
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Azure NAT Gateway](https://learn.microsoft.com/azure/nat-gateway/nat-overview)
- [Associate a NAT gateway to the subnet](https://learn.microsoft.com/azure/load-balancer/load-balancer-outbound-connections#2-associate-a-nat-gateway-to-the-subnet)
- [Default outbound access](https://learn.microsoft.com/azure/virtual-network/ip-services/default-outbound-access)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
