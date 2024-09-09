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
Rule 'Azure.AppService.NETVersion' -Ref 'AZR-000075' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2024_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $siteConfigs = @(GetWebSiteConfig)
    if ($siteConfigs.Length -eq 0) {
        if ($Assert.HasFieldValue($TargetObject, 'properties.siteConfig.linuxFxVersion').Result -and $TargetObject.properties.siteConfig.linuxFxVersion -like 'DOTNETCORE|*') {
            $linuxVersion = $TargetObject.properties.siteConfig.linuxFxVersion.Split('|')[1];
            return $Assert.Version($linuxVersion, '.', '>=8.0').PathPrefix('properties.siteConfig.linuxFxVersion');
        }
        elseif (!$Assert.HasDefaultValue($TargetObject, 'properties.siteConfig.netFrameworkVersion', 'OFF').Result -and
            ![String]::IsNullOrEmpty($TargetObject.properties.siteConfig.netFrameworkVersion)) {
            return $Assert.Version($TargetObject, 'properties.siteConfig.netFrameworkVersion', '4.0 || >=8.0');
        }
        else {
            return $Assert.Pass();
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        $path = $siteConfig._PSRule.path;
        if ($Assert.HasFieldValue($siteConfig, 'properties.linuxFxVersion').Result -and $siteConfig.properties.linuxFxVersion -like 'DOTNETCORE|*') {
            $linuxVersion = $siteConfig.properties.linuxFxVersion.Split('|')[1];
            $Assert.Version($linuxVersion, '.', '>=8.0').PathPrefix("$path.properties.linuxFxVersion");
        }
        elseif (!$Assert.HasDefaultValue($siteConfig, 'properties.netFrameworkVersion', 'OFF').Result -and
            ![String]::IsNullOrEmpty($siteConfig.properties.netFrameworkVersion)) {
            $Assert.Version($siteConfig, 'properties.netFrameworkVersion', '4.0 || >=8.0').PathPrefix($path);
        }
        else {
            $Assert.Pass();
        }
    }
}

# Synopsis: Configure applications to use newer PHP runtime versions.
Rule 'Azure.AppService.PHPVersion' -Ref 'AZR-000076' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/slots' -Tag @{ release = 'GA'; ruleSet = '2024_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $siteConfigs = @(GetWebSiteConfig)
    if ($siteConfigs.Length -eq 0) {
        if ($Assert.HasFieldValue($TargetObject, 'properties.siteConfig.linuxFxVersion').Result -and $TargetObject.properties.siteConfig.linuxFxVersion -like 'PHP|*') {
            $linuxVersion = $TargetObject.properties.siteConfig.linuxFxVersion.Split('|')[1];
            return $Assert.Version($linuxVersion, '.', '>=8.2').PathPrefix('properties.siteConfig.linuxFxVersion');
        }
        elseif (!$Assert.HasDefaultValue($TargetObject, 'properties.siteConfig.phpVersion', 'OFF').Result -and
            ![String]::IsNullOrEmpty($TargetObject.properties.siteConfig.phpVersion)) {
            return $Assert.Version($TargetObject, 'properties.siteConfig.phpVersion', '>=8.2');
        }
        else {
            return $Assert.Pass();
        }
    }
    foreach ($siteConfig in $siteConfigs) {
        $path = $siteConfig._PSRule.path;
        if ($Assert.HasFieldValue($siteConfig, 'properties.linuxFxVersion').Result -and $siteConfig.properties.linuxFxVersion -like 'PHP|*') {
            $linuxVersion = $siteConfig.properties.linuxFxVersion.Split('|')[1];
            $Assert.Version($linuxVersion, '.', '>=8.2').PathPrefix("$path.properties.linuxFxVersion");
        }
        elseif (!$Assert.HasDefaultValue($siteConfig, 'properties.phpVersion', 'OFF').Result -and
            ![String]::IsNullOrEmpty($siteConfig.properties.phpVersion)) {
            $Assert.Version($siteConfig, 'properties.phpVersion', '>=8.2').PathPrefix($path);
        }
        else {
            $Assert.Pass();
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
        $Assert.HasFieldValue($siteConfig, 'properties.alwaysOn', $True);
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

# Synopsis: Configure applications to use supported Node.js runtime versions.
Rule 'Azure.AppService.NodeJsVersion' -Ref 'AZR-000428' -Type 'Microsoft.Web/sites', 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots', 'Microsoft.Web/sites/slots/config' -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $versions = Get-NodeVersions

    $pass = $true
    foreach ($version in $versions) {
        if ($version -lt '20.0') {
            $pass = $false
            $Assert.Version($version.ToString(), '.', '>=20.0.0')
        }
    }

    # Pass if the version is not defined or version is 20 or greater.
    if ($pass) {
        $Assert.Pass()
    }
}

# Synopsis: Deploy app service plan instances using availability zones in supported regions to ensure high availability and resilience.
Rule 'Azure.AppService.AvailabilityZone' -Ref 'AZR-000442' -Type 'Microsoft.Web/serverfarms' -Tag @{ release = 'GA'; ruleSet = '2024_09 '; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check if the region supports availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets') # Use VMSS provider for availability zones as the App Service provider does not provide this information.
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings

    # Don't flag if the region does not support availability zones.
    if (-not $availabilityZones) {
        return $Assert.Pass()
    }

    # Availability zones are only supported for these Premium SKUs.
    $sku = [PSCustomObject]@{
        name = @(
            'P1v3' 
            'P1mv3'
            'P2v3'   
            'P2mv3' 
            'P3v3'    
            'P3mv3'
            'P4mv3'
            'P5mv3'
            'P1v2'
            'P2v2'
            'P3v2'
            'EP1'
            'EP2'
            'EP3'
        )
        tier = @(
            'PremiumV3'
            'PremiumV2'
            'ElasticPremium'
        )
    }

    AnyOf {
        $Assert.In($TargetObject, 'sku.name', $sku.name).ReasonFrom(
            'sku.name',
            $LocalizedData.AppServiceAvailabilityZoneSKU,
            $TargetObject.name
        )
        $Assert.In($TargetObject, 'sku.tier', $sku.tier).ReasonFrom(
            'sku.tier',
            $LocalizedData.AppServiceAvailabilityZoneSKU,
            $TargetObject.name
        )
    }

    $Assert.HasFieldValue($TargetObject, 'properties.zoneRedundant', $true)
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

function global:Get-NodeVersions {
    <#
    .SYNOPSIS
        Get the Node.js versions for the App Service.

    .DESCRIPTION
        This function retrieves the Node.js versions for the App Service.

    .OUTPUTS
        Output is a list of Node.js versions used, except the 'NODE|lts' version as this is not version specific,
        hence not parsable.
    #>
    [CmdletBinding()]
    param ( )
    
    [Version[]]$versions = @(
        # App Service on Linux. Works when main object equals Microsoft.Web/sites or Microsoft.Web/sites/slots
        $TargetObject.properties.siteConfig.linuxFxVersion | Where-Object { $_ -like 'NODE|*' -and $_ -ne 'NODE|lts' }
        # App Service on Linux. Works for when main object equals Microsoft.Web/sites/config 'web' or Microsoft.Web/sites/slots/config 'web'
        $TargetObject.properties.linuxFxVersion | Where-Object { $_ -like 'NODE|*' -and $_ -ne 'NODE|lts' }
        # App Service on Linux.
        GetSubResources -ResourceType 'Microsoft.Web/sites/slots' | 
        ForEach-Object { $_.properties.siteConfig.linuxFxVersion | Where-Object { $_ -like 'NODE|*' -and $_ -ne 'NODE|lts' } }
        # App Service on Linux.
        GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' |
        Where-Object { $_.name -eq 'web' -or $_.name -like '*/web' } |
        ForEach-Object { $_.properties.linuxFxVersion | Where-Object { $_ -like 'NODE|*' -and $_ -ne 'NODE|lts' } }
        
        # App Service on Windows. Works for when main object equals Microsoft.Web/sites or Microsoft.Web/sites/slots
        $TargetObject.properties.siteConfig.appSettings | Where-Object name -eq 'WEBSITE_NODE_DEFAULT_VERSION' | ForEach-Object { $_.value }
        # App Service on Windows. Works for when main object equals Microsoft.Web/sites/config 'appsettings' or Microsoft.Web/sites/slots/config 'appsettings'
        $TargetObject.properties.WEBSITE_NODE_DEFAULT_VERSION
        # App Service on Windows. Works for when main object equals Microsoft.Web/sites/config 'web' or Microsoft.Web/sites/slots/config 'web'
        $TargetObject.properties.appSettings | Where-Object name -eq 'WEBSITE_NODE_DEFAULT_VERSION' | ForEach-Object { $_.value }
        # App Service on Windows.
        GetSubResources -ResourceType 'Microsoft.Web/sites/slots' |
        ForEach-Object { $_.properties.siteConfig.appSettings | Where-Object name -eq 'WEBSITE_NODE_DEFAULT_VERSION' | ForEach-Object { $_.value } }
        # App Service on Windows.
        GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' |
        Where-Object { $_.name -eq 'appsettings' -or $_.name -like '*/appsettings' } |
        ForEach-Object { $_.properties.WEBSITE_NODE_DEFAULT_VERSION }
        # App Service on Windows.
        GetSubResources -ResourceType 'Microsoft.Web/sites/config', 'Microsoft.Web/sites/slots/config' |
        Where-Object { $_.name -eq 'web' -or $_.name -like '*/web' } |
        ForEach-Object { $_.properties.appSettings | Where-Object name -eq 'WEBSITE_NODE_DEFAULT_VERSION' | ForEach-Object { $_.value } }
    ) -replace '[^\d.]' -match '.' -replace '^\d+$', '$0.0'
    $versions
}

#endregion Helper functions
