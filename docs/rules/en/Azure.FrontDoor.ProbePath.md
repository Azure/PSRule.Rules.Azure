---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.ProbePath.md
---

# Use a dedicated health endpoint for Front Door backends

## SYNOPSIS

Configure a dedicated path for health probe requests.

## DESCRIPTION

Azure Front Door monitors a specific path for each backend to determine health status.
The monitored path should implement functional checks to determine if the backend is performing correctly.
The checks should include dependencies including those that may not be regularly called.

Regular checks of the monitored path allow Front Door to make load balancing decisions based on status.

## RECOMMENDATION

Consider using a dedicated health probe endpoint that implements functional checks.

## EXAMPLES

### Configure with Azure CLI

```bash
az network front-door probe update --front-door-name '<front_door>' -n '<probe_name>' -g '<resource_group>' --path '<path>'
```

### Configure with Azure PowerShell

```powershell
$probeSetting = New-AzFrontDoorHealthProbeSettingObject -Name '<probe_name>' -Path '<path>'
Set-AzFrontDoor -Name '<front_door>' -ResourceGroupName '<resource_group>' -HealthProbeSetting $probeSetting
```

## LINKS

- [Health probes](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes)
- [How Front Door determines backend health](https://docs.microsoft.com/azure/frontdoor/front-door-health-probes#how-front-door-determines-backend-health)
- [Creating good health probes](https://docs.microsoft.com/azure/architecture/framework/resiliency/monitoring#creating-good-health-probes)
- [Health Endpoint Monitoring pattern](https://docs.microsoft.com/azure/architecture/patterns/health-endpoint-monitoring)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.network/frontdoors#HealthProbeSettingsProperties)
