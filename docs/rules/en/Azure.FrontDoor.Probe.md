---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.Probe.md
---

# Use health probes for Front Door backends

## SYNOPSIS

Configure and enable health probes for each backend pool.

## DESCRIPTION

The health and performance of an application can degrade over time.
Degradation might not be noticeable until the application fails.

Azure Front Door can use periodic health probes against backend endpoints to determine health status.
When one or more backend in a pool is healthy traffic is routed to healthy endpoints only.
If all endpoints in a pool is unhealthy Front Door sends the request to any enabled endpoint.

Health probes allow Front Door to select a backend endpoint able to respond to the request.

## RECOMMENDATION

Consider enabling a health probe for each Front Door backend endpoint.

## EXAMPLES

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --enabled 'Enabled'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -EnabledState 'Enabled'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

## LINKS

- [Health probes](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes)
- [How Front Door determines backend health](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes#how-front-door-determines-backend-health)
- [Creating good health probes](https://docs.microsoft.com/azure/architecture/framework/resiliency/monitoring#creating-good-health-probes)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)
