# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Front Door
#

#region Front Door

# Synopsis: Front Door instance should be enabled
Rule 'Azure.FrontDoor.State' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enabledState', 'Enabled');
}

# Synopsis: Use a minimum of TLS 1.2
Rule 'Azure.FrontDoor.MinTLS' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasDefaultValue($endpoint, 'properties.customHttpsConfiguration.minimumTlsVersion', '1.2');
    }
}

# Synopsis: Use diagnostics to audit Front Door access
Rule 'Azure.FrontDoor.Logs' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
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

# Synopsis: Enable WAF policy of each endpoint
Rule 'Azure.FrontDoor.UseWAF' -Type 'Microsoft.Network/frontDoors', 'Microsoft.Network/frontDoors/frontendEndpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $endpoints = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Network/frontDoors') {
        $endpoints = @($TargetObject.Properties.frontendEndpoints);
    }
    foreach ($endpoint in $endpoints) {
        $Assert.HasFieldValue($endpoint, 'properties.webApplicationFirewallPolicyLink.id');
    }
}

# Synopsis: Use Front Door naming requirements
Rule 'Azure.FrontDoor.Name' -Type 'Microsoft.Network/frontDoors' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 5 and 64 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 5);
    $Assert.LessOrEqual($PSRule, 'TargetName', 64);

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z](-|[A-Za-z0-9])*[A-Za-z0-9]$');
}

# Synopsis: Use Front Door WAF policy in prevention mode
Rule 'Azure.FrontDoor.WAF.Mode' -Type 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policySettings.mode', 'Prevention');
}

# Synopsis: Enable Front Door WAF policy
Rule 'Azure.FrontDoor.WAF.Enabled' -Type 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policySettings.enabledState', 'Enabled');
}

# Synopsis: Use Front Door WAF naming requirements
Rule 'Azure.FrontDoor.WAF.Name' -Type 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    # Between 1 and 128 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 128);

    # Letters or numbers
    # Start letter
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z][A-Za-z0-9]{0,127}$');
}

#endregion Front Door
