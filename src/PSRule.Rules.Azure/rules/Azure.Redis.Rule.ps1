# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Redis Cache
#

# Synopsis: Configure `maxmemory-reserved` to reserve memory for non-cache operations.
Rule 'Azure.Redis.MaxMemoryReserved' -Ref 'AZR-000160' -Type 'Microsoft.Cache/Redis' -With 'Azure.Redis.HasSku' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $sku = "$($TargetObject.Properties.sku.family)$($TargetObject.Properties.sku.capacity)";
    if (![String]::IsNullOrEmpty($sku)) {
        $memSize = (GetCacheMemory -Sku $sku) / 1MB;
        $Assert.GreaterOrEqual($TargetObject, 'Properties.redisConfiguration.maxmemory-reserved', $memSize * 0.1, $True);
    }
}

# Synopsis: Premium Redis cache should be deployed with availability zones for high availability.
Rule 'Azure.Redis.AvailabilityZone' -Ref 'AZR-000161' -Type 'Microsoft.Cache/Redis' -If { IsPremiumCache } -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $redisCacheProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Cache', 'Redis');

    $configurationZoneMappings = $Configuration.AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $redisCacheProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $locationAvailabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $locationAvailabilityZones) {
        return $Assert.Pass();
    }

    # Need to check zones are greater or equal to 2 and replicas are n(number of zones) - 1
    $Assert.AllOf(
        $Assert.GreaterOrEqual($TargetObject, 'Properties.replicasPerMaster', $TargetObject.zones.Length - 1),
        $Assert.GreaterOrEqual($TargetObject, 'zones', 2),
        $Assert.In($TargetObject, 'Properties.sku.capacity', @(1, 2, 3, 4, 5))
    ).Reason(
        $LocalizedData.PremiumRedisCacheAvailabilityZone, 
        $TargetObject.name, 
        $TargetObject.location, 
        ($locationAvailabilityZones -join ', ')
    );

} -Configure @{ AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

# Synopsis: Enterprise Redis cache should be zone-redundant for high availability.
Rule 'Azure.RedisEnterprise.Zones' -Ref 'AZR-000162' -Type 'Microsoft.Cache/redisEnterprise' -If { IsEnterpriseCache } -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $redisEnterpriseCacheProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Cache', 'redisEnterprise');

    $configurationZoneMappings = $Configuration.AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $redisEnterpriseCacheProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $locationAvailabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $locationAvailabilityZones) {
        return $Assert.Pass();
    }

    $capacityUnitMapping = @{
        'Enterprise'      = @(2, 4, 6, 8, 10)
        'EnterpriseFlash' = @(3, 9)
    }

    $skuPrefix = $TargetObject.sku.name.Split('_')[0];

    # Check if zone redundant(1, 2 and 3)
    $Assert.AllOf(
        $Assert.SetOf($TargetObject, 'zones', @('1', '2', '3')),
        $Assert.In($TargetObject, 'sku.capacity', $capacityUnitMapping[$skuPrefix])
    ).Reason(
        $LocalizedData.EnterpriseRedisCacheAvailabilityZone,
        $TargetObject.name,
        $TargetObject.location
    );

} -Configure @{ AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

# Synopsis: Determine if there is an excessive number of firewall rules for the Redis cache.
Rule 'Azure.Redis.FirewallRuleCount' -Ref 'AZR-000299' -Type 'Microsoft.Cache/redis', 'Microsoft.Cache/redis/firewallRules' -If { HasPublicNetworkAccess } -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } {

    $services = @($TargetObject);

    if ($PSRule.TargetType -eq 'Microsoft.Cache/redis') {
        $services = @(GetSubResources -ResourceType 'Microsoft.Cache/redis/firewallRules');
    }

    if ($services.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Cache/redis/firewallRules');
    }

    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.Cache/redis/firewallRules');
    $Assert.
    LessOrEqual($firewallRules, '.', 10).
    WithReason(($LocalizedData.ExceededFirewallRuleCount -f $firewallRules.Length, 10), $True);
}

# Synopsis: Determine if there is an excessive number of permitted IP addresses for the Redis cache.
Rule 'Azure.Redis.FirewallIPRange' -Ref 'AZR-000300' -Type 'Microsoft.Cache/redis', 'Microsoft.Cache/redis/firewallRules' -If { HasPublicNetworkAccess } -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } {

    $services = @($TargetObject);

    if ($PSRule.TargetType -eq 'Microsoft.Cache/redis') {
        $services = @(GetSubResources -ResourceType 'Microsoft.Cache/redis/firewallRules');
    }

    if ($services.Length -eq 0) {
        return $Assert.Fail($LocalizedData.SubResourceNotFound, 'Microsoft.Cache/redis/firewallRules');
    }

    $summary = GetIPAddressSummary
    $summary.Public = [int32]$summary.Public # Had to convert $summary.Public to int32 from uint64.

    $Assert.
    LessOrEqual($summary, 'Public', 10).
    WithReason(($LocalizedData.DBServerFirewallPublicIPRange -f $summary.Public, 10), $True); 
}

# Synopsis: Azure Cache for Redis should use the latest supported version of Redis.
Rule 'Azure.Redis.Version' -Ref 'AZR-000347' -Type 'Microsoft.Cache/redis' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.AnyOf(
        $Assert.HasDefaultValue($TargetObject, 'properties.redisVersion', 'latest'),
        $Assert.Version($TargetObject, 'properties.redisVersion', '>=6')
    ).Reason($LocalizedData.AzureCacheRedisVersion)
}

# Synopsis: Azure Cache for Redis is being retired. Migrate to Azure Managed Redis.
Rule 'Azure.Redis.MigrateAMR' -Ref 'AZR-000533' -Type 'Microsoft.Cache/redis' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.Fail($LocalizedData.CacheRedisMigrateAMR)
}

# Synopsis: Redis Enterprise and Enterprise Flash are being retired. Migrate to Azure Managed Redis.
Rule 'Azure.RedisEnterprise.MigrateAMR' -Ref 'AZR-000534' -Type 'Microsoft.Cache/redisEnterprise' -If { IsEnterpriseCache } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.Fail($LocalizedData.RedisEnterpriseMigrateAMR)
}

#region Helper functions

function global:GetCacheMemory {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Sku
    )
    process {
        switch ($Sku) {
            "C0" { return 250MB; }
            "C1" { return 1GB; }
            "C2" { return 2.5GB; }
            "C3" { return 6GB; }
            "C4" { return 13GB; }
            "C5" { return 26GB; }
            "C6" { return 53GB; }
            "P1" { return 6GB; }
            "P2" { return 13GB; }
            "P3" { return 26GB; }
            "P4" { return 53GB; }
            "P5" { return 120GB; }
        }
    }
}

function global:IsPremiumCache {
    [CmdletBinding()]
    [OutputType([PSRule.Runtime.AssertResult])]
    param ()
    process {
        return $Assert.AllOf(
            $Assert.HasFieldValue($TargetObject, 'Properties.sku.name', 'Premium'),
            $Assert.HasFieldValue($TargetObject, 'Properties.sku.family', 'P')
        );
    }
}

function global:IsEnterpriseCache {
    [CmdletBinding()]
    [OutputType([PSRule.Runtime.AssertResult])]
    param ()
    process {
        return $Assert.In($TargetObject, 'sku.name', @(
                'Enterprise_E10', 
                'Enterprise_E20', 
                'Enterprise_E50',
                'Enterprise_E100',
                'EnterpriseFlash_F300',
                'EnterpriseFlash_F700',
                'EnterpriseFlash_F1500'));
    }
}

function global:HasPublicNetworkAccess {
    [CmdletBinding()]
    param ()
    process {
        return $PSRule.TargetType -eq 'Microsoft.Cache/redis/firewallRules' -or ($PSRule.TargetType -eq 'Microsoft.Cache/redis' -and $TargetObject.properties.publicNetworkAccess -ne 'Disabled')
    }
}

#endregion Helper functions
