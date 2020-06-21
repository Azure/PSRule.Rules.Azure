# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Traffic Manager resources
#

# Synopsis: Traffic Manager should use at lest two enabled endpoints
Rule 'Azure.TrafficManager.Endpoints' -Type 'Microsoft.Network/trafficManagerProfiles' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $endpoints = @($TargetObject.Properties.endpoints | Where-Object { $_.Properties.endpointStatus -eq 'Enabled'});
    $Assert.Create($endpoints.Length -ge 2, ($LocalizedData.EnabledEndpoints -f $endpoints.Length))
}

# Synopsis: Monitor Traffic Manager endpoints with HTTPS
Rule 'Azure.TrafficManager.Protocol' -Type 'Microsoft.Network/trafficManagerProfiles' -If { (IsHttpMonitor) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.monitorConfig.protocol', 'HTTPS');
}

function global:IsHttpMonitor {
    [CmdletBinding()]
    param ()
    process {
        return $TargetObject.Properties.monitorConfig.port -in 80, 443;
    }
}
