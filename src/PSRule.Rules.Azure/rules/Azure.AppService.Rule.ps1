# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Services
#

# Synopsis: App Service Plan should use a minimum number of instances for failover.
Rule 'Azure.AppService.PlanInstanceCount' -Ref 'AZR-000071' -Type 'Microsoft.Web/serverfarms' -If { !(IsConsumptionPlan) -and !(IsElasticPlan) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.GreaterOrEqual($TargetObject, 'sku.capacity', 2);
}

# Synopsis: App Service should reject TLS versions older than 1.2.
Rule 'Azure.AppService.MinTLS' -Ref 'AZR-000073' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.
            HasFieldValue($TargetObject, 'properties.siteConfig.minTlsVersion', '1.2').
            ReasonFrom('properties.siteConfig.minTlsVersion', $LocalizedData.MinTLSVersion, $TargetObject.properties.siteConfig.minTlsVersion);
    }
    foreach ($siteConfig in $siteConfigs) {
        $path = $siteConfig._PSRule.path;
        $Assert.
            HasFieldValue($siteConfig, 'properties.minTlsVersion', '1.2').
            ReasonFrom('properties.minTlsVersion', $LocalizedData.MinTLSVersion, $siteConfig.properties.minTlsVersion).PathPrefix($path);
    }
}

# Synopsis: Disable remote debugging on App Service apps when not in use.
Rule 'Azure.AppService.RemoteDebug' -Ref 'AZR-000074' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PV-2' } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasDefaultValue($TargetObject, 'properties.siteConfig.remoteDebuggingEnabled', $False);
    }
    foreach ($siteConfig in $siteConfigs) {
        $path = $siteConfig._PSRule.path;
        $Assert.HasDefaultValue($siteConfig, 'properties.remoteDebuggingEnabled', $False).PathPrefix($path);
    }
}

# Synopsis: Configure applications to use newer .NET Framework versions.
Rule 'Azure.AppService.NETVersion' -Ref 'AZR-000075' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.netFrameworkVersion)
    })
    if ($siteConfigs.Length -eq 0) {
        return AnyOf {
            $Assert.HasDefaultValue($TargetObject, 'properties.siteConfig.netFrameworkVersion', 'OFF');
            $Assert.Version($TargetObject, 'properties.siteConfig.netFrameworkVersion', '>=4.0');
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        $path = $siteConfig._PSRule.path;
        AnyOf {
            $Assert.HasFieldValue($siteConfig, 'properties.netFrameworkVersion', 'OFF').PathPrefix($path)
            $Assert.Version($siteConfig, 'properties.netFrameworkVersion', '>=4.0').PathPrefix($path)
        }
    }
}

# Synopsis: Configure applications to use newer PHP runtime versions.
Rule 'Azure.AppService.PHPVersion' -Ref 'AZR-000076' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        ![String]::IsNullOrEmpty($_.Properties.phpVersion)
    })
    if ($siteConfigs.Length -eq 0) {
        return AnyOf {
            $Assert.HasDefaultValue($TargetObject, 'Properties.siteConfig.phpVersion', 'OFF')
            $Assert.Version($TargetObject, 'Properties.siteConfig.phpVersion', '>=7.0')
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        AnyOf {
            $Assert.HasFieldValue($siteConfig, 'Properties.phpVersion', 'OFF')
            $Assert.Version($siteConfig, 'Properties.phpVersion', '>=7.0')
        }
    }
}

# Synopsis: Configure Always On for App Service apps.
Rule 'Azure.AppService.AlwaysOn' -Ref 'AZR-000077' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -With 'Azure.AppService.IsWebApp', 'Azure.AppService.IsAPIApp' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasFieldValue($TargetObject, 'Properties.siteConfig.alwaysOn', $True);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'Properties.alwaysOn', $True);
    }
}

# Synopsis: Use HTTP/2 for App Service apps.
Rule 'Azure.AppService.HTTP2' -Ref 'AZR-000078' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $siteConfigs = @(GetWebSiteConfig);
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasFieldValue($TargetObject, 'Properties.siteConfig.http20Enabled', $True);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'Properties.http20Enabled', $True);
    }
}

#region Web Apps

# Synopsis: Configure and enable instance health probes.
Rule 'Azure.AppService.WebProbe' -Ref 'AZR-000079' -With 'Azure.AppService.IsWebApp' -Tag @{ release = 'GA'; ruleSet = '2022_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        $Assert.HasField($_, 'Properties.healthCheckPath').Result
    });
    if ($siteConfigs.Length -eq 0) {
        return $Assert.HasFieldValue($TargetObject, 'properties.siteConfig.healthCheckPath');
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.HasFieldValue($siteConfig, 'properties.healthCheckPath');
    }
}

# Synopsis: Web apps should use a dedicated health check path.
Rule 'Azure.AppService.WebProbePath' -Ref 'AZR-000080' -With 'Azure.AppService.IsWebApp' -Tag @{ release = 'GA'; ruleSet = '2022_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        $Assert.HasField($_, 'properties.healthCheckPath').Result
    });
    if ($siteConfigs.Length -eq 0) {
        return $Assert.Greater($TargetObject, 'properties.siteConfig.healthCheckPath', 1);
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.Greater($siteConfig, 'properties.healthCheckPath', 1);
    }
}

# Synopsis: Web apps should disable insecure FTP and configure SFTP when required.
Rule 'Azure.AppService.WebSecureFtp' -Ref 'AZR-000081' -With 'Azure.AppService.IsWebApp' -Tag @{ release = 'GA'; ruleSet = '2022_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $siteConfigs = @(GetWebSiteConfig | Where-Object {
        $Assert.HasField($_, 'Properties.ftpsState').Result
    });
    if ($siteConfigs.Length -eq 0) {
        return $Assert.In($TargetObject, 'Properties.siteConfig.ftpsState', @(
            'FtpsOnly'
            'Disabled'
        ));
    }
    foreach ($siteConfig in $siteConfigs) {
        $Assert.In($siteConfig, 'Properties.ftpsState', @(
            'FtpsOnly'
            'Disabled'
        ));
    }
}

#endregion Web Apps

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

function global:IsElasticPlan {
    [CmdletBinding()]
    param ()
    process {
        return (
            $TargetObject.sku.Name -like 'EP*' -or
            $TargetObject.sku.Tier -eq 'ElasticPremium' -or
            $TargetObject.kind -eq 'elastic'
        );
    }
}

function global:GetWebSiteConfig {
    [CmdletBinding()]
    param ()
    process {
        $siteConfigs = @(GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' | Where-Object {
            $_.Name -notlike "*/*" -or $_.Name -like "*/web" -or $_.Id -like "*/web"
        })
        $siteConfigs;
    }
}

#endregion Helper functions
