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
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.
            HasFieldValue($TargetObject, 'Properties.siteConfig.minTlsVersion', '1.2').
            Reason($LocalizedData.MinTLSVersion, $TargetObject.Properties.siteConfig.minTlsVersion);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.
            HasFieldValue($siteConfig, 'Properties.minTlsVersion', '1.2').
            Reason($LocalizedData.MinTLSVersion, $siteConfig.Properties.minTlsVersion);
    }
}

# Synopsis: Disable remote debugging
Rule 'Azure.AppService.RemoteDebug' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasDefaultValue($TargetObject, 'Properties.siteConfig.remoteDebuggingEnabled', $False);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasDefaultValue($siteConfig, 'Properties.remoteDebuggingEnabled', $False);
    }
}

# Synopsis: Configure applications to use newer .NET Framework versions.
Rule 'Azure.AppService.NETVersion' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.netFrameworkVersion)
    })
    if ($siteConfigs.Length -eq 0) {
        return AnyOf {
            $Assert.HasDefaultValue($TargetObject, 'Properties.siteConfig.netFrameworkVersion', 'OFF')
            $Assert.Version($TargetObject, 'Properties.siteConfig.netFrameworkVersion', '^4.0')
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        AnyOf {
            $Assert.HasFieldValue($siteConfig, 'Properties.netFrameworkVersion', 'OFF')
            $Assert.Version($siteConfig, 'Properties.netFrameworkVersion', '^4.0')
        }
    }
}

# Synopsis: Configure applications to use newer PHP runtime versions.
Rule 'Azure.AppService.PHPVersion' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.phpVersion)
    })
    if ($siteConfigs.Length -eq 0) {
        return AnyOf {
            $Assert.HasDefaultValue($TargetObject, 'Properties.siteConfig.phpVersion', 'OFF')
            $Assert.Version($TargetObject, 'Properties.siteConfig.phpVersion', '^7.0')
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        AnyOf {
            $Assert.HasFieldValue($siteConfig, 'Properties.phpVersion', 'OFF')
            $Assert.Version($siteConfig, 'Properties.phpVersion', '^7.0')
        }
    }
}

# Synopsis: Configure Always On for App Service apps.
Rule 'Azure.AppService.AlwaysOn' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasFieldValue($TargetObject, 'Properties.siteConfig.alwaysOn', $True);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'Properties.alwaysOn', $True);
    }
}

# Synopsis: Use HTTP/2 for App Service apps.
Rule 'Azure.AppService.HTTP2' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasFieldValue($TargetObject, 'Properties.siteConfig.http20Enabled', $True);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'Properties.http20Enabled', $True);
    }
}

# Synopsis: Use a Managed Identities with Azure Service apps.
Rule 'Azure.AppService.ManagedIdentity' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    $Assert.In($TargetObject, 'Identity.Type', @('SystemAssigned', 'UserAssigned'));
}

#region Helper functions

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

function global:GetWebSiteConfig {
    [CmdletBinding()]
    param ()
    process {
        $siteConfigs = @(GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' | Where-Object {
            $_.Name -notlike "*/*" -or $_.Name -like "*/web"
        })
        $siteConfigs;
    }
}

#endregion Helper functions
