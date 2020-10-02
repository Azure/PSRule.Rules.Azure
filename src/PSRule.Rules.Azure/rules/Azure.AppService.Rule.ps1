# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Services
#

# Synopsis: Use an App Service Plan with at least two (2) instances
Rule 'Azure.AppService.PlanInstanceCount' -Type 'Microsoft.Web/serverfarms' -If { !(IsConsumptionPlan) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.GreaterOrEqual($TargetObject, 'Sku.capacity', 2);
}

# Synopsis: Use at least a Standard App Service Plan
Rule 'Azure.AppService.MinPlan' -Type 'Microsoft.Web/serverfarms' -If { !(IsConsumptionPlan) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Sku.tier', @('PremiumV2', 'Premium', 'Standard'))
}

# Synopsis: Disable client affinity for stateless services
Rule 'Azure.AppService.ARRAffinity' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.clientAffinityEnabled', $False)
}

# Synopsis: Use HTTPS only
Rule 'Azure.AppService.UseHTTPS' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.httpsOnly', $True)
}

# Synopsis: Use at least TLS 1.2
Rule 'Azure.AppService.MinTLS' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $siteConfigs = GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config'
    foreach ($siteConfig in $siteConfigs) {
        $Assert.
            HasFieldValue($siteConfig, 'Properties.minTlsVersion', '1.2').
            Reason($LocalizedData.MinTLSVersion, $siteConfig.Properties.minTlsVersion);
    }
}

# Synopsis: Disable remote debugging
Rule 'Azure.AppService.RemoteDebug' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config'
    if ($siteConfigs.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasDefaultValue($siteConfig, 'Properties.remoteDebuggingEnabled', $False);
    }
}

# Synopsis: Configure applications to use newer .NET Framework versions.
Rule 'Azure.AppService.NETVersion' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.netFrameworkVersion) -and $_.Properties.netFrameworkVersion -ne 'OFF'
    })
    if ($siteConfigs.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.Version($siteConfig, 'Properties.netFrameworkVersion', '^4.0')
    }
}

# Synopsis: Configure applications to use newer PHP runtime versions.
Rule 'Azure.AppService.PHPVersion' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.phpVersion) -and $_.Properties.phpVersion -ne 'OFF'
    })
    if ($siteConfigs.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.Version($siteConfig, 'Properties.phpVersion', '^7.0')
    }
}

# Synopsis: Configure Always On for App Service apps.
Rule 'Azure.AppService.AlwaysOn' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config'
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'Properties.alwaysOn', $True);
    }
}

function global:IsConsumptionPlan {
    [CmdletBinding()]
    param ()
    process {
        return (
            $TargetObject.sku.Name -eq 'Y1' -or
            $TargetObject.sku.Tier -eq 'Dynamic'
        );
    }
}
