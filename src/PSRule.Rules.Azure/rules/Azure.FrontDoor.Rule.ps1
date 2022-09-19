# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Front Door
#

#region Front Door

# Synopsis: Front Door should reject TLS versions older then 1.2.
Rule 'Azure.FrontDoor.MinTLS' -Ref 'AZR-000106' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; 'Azure.ASB.v3/control' = 'DP-3' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasDefaultValue($endpoint, 'properties.customHttpsConfiguration.minimumTlsVersion', '1.2');
    }
}

# Synopsis: Use diagnostics to audit Front Door access
Rule 'Azure.FrontDoor.Logs' -Ref 'AZR-000107' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.DiagnosticSettingsNotConfigured;
    $diagnostics = @(GetSubResources -ResourceType 'microsoft.insights/diagnosticSettings', 'Microsoft.Network/frontDoors/providers/diagnosticSettings');
    $logCategories = @($diagnostics | ForEach-Object {
        foreach ($log in $_.Properties.logs) {
            if ($log.category -eq 'FrontdoorAccessLog' -and $log.enabled -eq $True) {
                $log;
            }
        }
    });
    $Null -ne $logCategories -and $logCategories.Length -gt 0;
}

# Synopsis: Configure and enable health probes for each backend pool.
Rule 'Azure.FrontDoor.Probe' -Ref 'AZR-000108' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.Properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.HasFieldValue($probe, 'properties.enabledState', 'Enabled');
    }
}

# Synopsis: Configure health probes to use HEAD instead of GET requests.
Rule 'Azure.FrontDoor.ProbeMethod' -Ref 'AZR-000109' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.Properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.HasFieldValue($probe, 'properties.healthProbeMethod', 'Head');
    }
}

# Synopsis: Configure a dedicated path for health probe requests.
Rule 'Azure.FrontDoor.ProbePath' -Ref 'AZR-000110' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.Properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.NotIn($probe, 'properties.path', '/').Reason($LocalizedData.HealthProbeNotDedicated, $probe.name);
    }
}

# Synopsis: Enable Web Application Firewall (WAF) policies on each Front Door endpoint.
Rule 'Azure.FrontDoor.UseWAF' -Ref 'AZR-000111' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; 'Azure.ASB.v3/control' = 'NS-6' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasFieldValue($endpoint, 'properties.webApplicationFirewallPolicyLink.id');
    }
}

#endregion Front Door
