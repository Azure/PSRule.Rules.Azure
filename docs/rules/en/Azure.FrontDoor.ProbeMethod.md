---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.ProbeMethod.md
---

# Use HEAD health probes for Front Door backends

## SYNOPSIS

Configure health probes to use HEAD instead of GET requests.

## DESCRIPTION

Azure Front Door supports sending HEAD or GET requests for health probes to backend endpoints.
HTTP HEAD requests are identical to GET requests except that the server does not send a response body.
To lower load and performance cost against backends use HEAD requests.

## RECOMMENDATION

Consider configuring health probes to query backend health endpoints using HEAD requests.

## EXAMPLES

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --probeMethod  'HEAD'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -HealthProbeMethod 'HEAD'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

## LINKS

- [Supported HTTP methods for health probes](https://docs.microsoft.com/en-gb/azure/frontdoor/front-door-health-probes#supported-http-methods-for-health-probes)
- [How Front Door determines backend health](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes#how-front-door-determines-backend-health)
- [Creating good health probes](https://docs.microsoft.com/azure/architecture/framework/resiliency/monitoring#creating-good-health-probes)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)
