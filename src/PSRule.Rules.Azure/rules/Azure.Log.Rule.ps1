# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Azure Monitor
#


#region Rules

# Synopsis: The replication location determines the country or region where the data is stored and processed.
Rule 'Azure.Log.ReplicaLocation' -Ref 'AZR-000483' -Type 'Microsoft.OperationalInsights/workspaces' -If { $Assert.HasField($TargetObject, 'properties.replication.location') } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $context = $PSRule.GetService('Azure.Context');
    $locations = $PSRule.GetPath($TargetObject, 'properties.replication.location');
    if ($locations -eq $Null -or $locations.Length -eq 0) {
        return $Assert.Pass();
    }

    for ($i = 0; $i -lt $locations.Length; $i++) {
        $path = "properties.replication.location";
        [string]$location = $locations[$i];
        $Assert.Create($path, [bool]$context.IsAllowedLocation($location), $LocalizedData.LocationNotAllowed, @($location));
    }
}

# Synopsis: Azure Monitor Log workspaces without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Log.Naming' -Ref 'AZR-000487' -Type 'Microsoft.OperationalInsights/workspaces' -If { $Configuration['AZURE_LOG_WORKSPACE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_LOG_WORKSPACE_NAME_FORMAT, $True);
}

#endregion Rules
