# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Entra ID
#

#region Rules

# Synopsis: The location of a replica set determines the country or region where the data is stored and processed.
Rule 'Azure.EntraDS.ReplicaLocation' -Ref 'AZR-000482' -Type 'Microsoft.AAD/domainServices' -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $context = $PSRule.GetService('Azure.Context');
    $locations = $PSRule.GetPath($TargetObject, 'properties.replicaSets[*].location');
    if ($locations -eq $Null -or $locations.Length -eq 0) {
        return $Assert.Pass();
    }

    for ($i = 0; $i -lt $locations.Length; $i++) {
        $path = "properties.replicaSets[$i].location";
        [string]$location = $locations[$i];
        $Assert.Create($path, [bool]$context.IsAllowedLocation($location), $LocalizedData.LocationNotAllowed, @($location));
    }
}

#endregion Rules
