---
severity: Important
pillar: Security
category: Application endpoints
resource: Key Vault
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.KeyVault.Firewall/
---

# Configure Azure Key Vault firewall

## SYNOPSIS

Key Vault should only accept explicitly allowed traffic.

## DESCRIPTION

By default, Key Vault accept connections from clients on any network.
To limit access to selected networks, you must first change the default action.

After changing the default action from `Allow` to `Deny`, configure one or more rules to allow traffic.
Traffic can be allowed from:

- Azure services on the trusted service list.
- IP address or CIDR range.
- Private endpoint connections.
- Azure virtual network subnets with a Service Endpoint.

If any of the following options are enabled you must also enable _Allow trusted Microsoft services to bypass this firewall_:

- `enabledForDeployment` - _Azure Virtual Machines for deployment_.
- `enabledForDiskEncryption` - _Azure Disk Encryption for volume encryption_.
- `enabledForTemplateDeployment` - _Azure Resource Manager for template deployment_.

## RECOMMENDATION

Consider configuring KeyVault firewall to restrict network access to permitted clients only.
Also consider enforcing this setting using Azure Policy [Azure Key Vault should have firewall enabled](https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F55615ac9-af46-4a59-874e-391cc3dfb490).

## NOTES


## LINKS

- [Public endpoints](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints#public-endpoints)
- [Configure Azure Key Vault firewalls and virtual networks](https://docs.microsoft.com/azure/key-vault/general/network-security)
- [Azure security baseline for Key Vault - Disable Public Network Access](https://learn.microsoft.com/security/benchmark/azure/baselines/key-vault-security-baseline#disable-public-network-access)
- [Azure Policies - Azure Key Vault should have firewall enabled](https://www.azadvertizer.net/azpolicyadvertizer/55615ac9-af46-4a59-874e-391cc3dfb490.html)

