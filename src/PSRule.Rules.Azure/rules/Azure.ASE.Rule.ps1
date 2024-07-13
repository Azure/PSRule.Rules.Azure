# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Service Environment
#

#region Rules

# Synopsis: Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2.
Rule 'Azure.ASE.MigrateV3' -Ref 'AZR-000319' -Type 'Microsoft.Web/hostingEnvironments' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.HasFieldValue($TargetObject, 'kind', 'ASEV3').Reason($LocalizedData.ClassicASEDeprecated, $PSRule.TargetName, $TargetObject.kind)
}

# Synopsis: Deploy app service environments using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.ASE.AvailabilityZone' -Ref 'AZR-000443' -Type 'Microsoft.Web/hostingEnvironments' -Tag @{ release = 'GA'; ruleSet = '2024_09 '; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Dedicated host group does not support zone-redundancy.
    if ($TargetObject.properties.dedicatedHostCount) {
        return $Assert.Pass()
    }

    # Check if the region supports availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Web', 'hostingEnvironments')
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings

    # Don't flag if the region does not support availability zones.
    if (-not $availabilityZones) {
        return $Assert.Pass()
    }

    # Availability zones are only supported for the ASEv3 version (modern footprint).
    $Assert.HasFieldValue($TargetObject, 'kind', 'ASEV3').Reason(
        $LocalizedData.ASEAvailabilityZoneVersion,
        $TargetObject.name
    )

    $Assert.HasFieldValue($TargetObject, 'properties.zoneRedundant', $true)
}

#endregion Rules
