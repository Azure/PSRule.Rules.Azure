# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Front Door
#

#region Front Door

# Synopsis: Front Door should reject TLS versions older than 1.2.
Rule 'Azure.FrontDoor.MinTLS' -Ref 'AZR-000106' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3'; 'Azure.WAF/maturity' = 'L1' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasDefaultValue($endpoint, 'properties.customHttpsConfiguration.minimumTlsVersion', '1.2');
    }
}

# Synopsis: Audit and monitor access through Azure Front Door profiles.
Rule 'Azure.FrontDoor.Logs' -Ref 'AZR-000107' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Cdn/profiles' -With 'Azure.FrontDoor.IsStandardOrPremium', 'Azure.FrontDoor.IsClassic' -Tag @{ release = 'GA'; ruleSet = '2024_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4' } {
    $logCategoryGroups = 'audit', 'allLogs'
    $diagnostics = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.Network/frontDoors/providers/diagnosticSettings', 'Microsoft.Cdn/profiles/providers/diagnosticSettings' | ForEach-Object {
        $_.Properties.logs | Where-Object {
            ($_.category -eq 'FrontdoorAccessLog' -or $_.categoryGroup -in $logCategoryGroups) -and $_.enabled
        }
    })

    $Assert.Greater($diagnostics, '.', 0).ReasonFrom(
        'properties.logs',
        $LocalizedData.DiagnosticSettingsLoggingNotConfigured,
        'FrontdoorAccessLog'
    ).PathPrefix('resources[*]')
}

# Synopsis: Configure and enable health probes for each backend pool.
Rule 'Azure.FrontDoor.Probe' -Ref 'AZR-000108' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.HasFieldValue($probe, 'properties.enabledState', 'Enabled');
    }
}

# Synopsis: Configure health probes to use HEAD requests to reduce performance overhead.
Rule 'Azure.FrontDoor.ProbeMethod' -Ref 'AZR-000109' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.Properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.HasFieldValue($probe, 'properties.healthProbeMethod', 'Head');
    }
}

# Synopsis: Configure a dedicated path for health probe requests.
Rule 'Azure.FrontDoor.ProbePath' -Ref 'AZR-000110' -Type 'Microsoft.Network/frontdoors', 'Microsoft.Network/Frontdoors/HealthProbeSettings' -Tag @{ release = 'GA'; ruleSet = '2021_03'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $probes = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $probes = @($TargetObject.Properties.healthProbeSettings);
    }
    foreach ($probe in $probes) {
        $Assert.NotIn($probe, 'properties.path', '/').Reason($LocalizedData.HealthProbeNotDedicated, $probe.name);
    }
}

# Synopsis: Enable Web Application Firewall (WAF) policies on each Front Door endpoint.
Rule 'Azure.FrontDoor.UseWAF' -Ref 'AZR-000111' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-6' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasFieldValue($endpoint, 'properties.webApplicationFirewallPolicyLink.id');
    }
}

# Synopsis: Use caching to reduce retrieving contents from origins.
Rule 'Azure.FrontDoor.UseCaching' -Ref 'AZR-000320' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/rulesEngines' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $cachingDisabledRoutingRules = @($TargetObject.properties.routingRules | Where-Object { $_.properties.enabledState -eq 'Enabled' -and
            $_.properties.routeConfiguration.'@odata.type' -eq '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration' -and
                -not $_.properties.routeConfiguration.cacheConfiguration })
        $cachingDisabledRuleSets = @(GetSubResources -ResourceType 'Microsoft.Network/frontDoors/rulesEngines' | ForEach-Object { $_.properties.rules |
            Where-Object { $_.action.routeConfigurationOverride -and
                $_.action.routeConfigurationOverride.'@odata.type' -eq '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration' -and
                    -not $_.action.routeConfigurationOverride.cacheConfiguration } })
        
        $cachingDisabled = @($cachingDisabledRoutingRules; $cachingDisabledRuleSets)

        $Assert.Less($cachingDisabled, '.', 1).Reason($LocalizedData.FrontDoorCachingDisabled)
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors/rulesEngines') {
        $cachingDisabledRuleSet = @($TargetObject.properties.rules | Where-Object { $_.action.routeConfigurationOverride -and
            $_.action.routeConfigurationOverride.'@odata.type' -eq '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration' -and
                -not $_.action.routeConfigurationOverride.cacheConfiguration })

        $Assert.Less($cachingDisabledRuleSet, '.', 1).Reason($LocalizedData.FrontDoorCachingDisabled)
    }
}
