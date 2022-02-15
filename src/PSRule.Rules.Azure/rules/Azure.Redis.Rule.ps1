# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Redis Cache
#

# Synopsis: Use Azure Cache for Redis instances of at least Standard C1.
Rule 'Azure.Redis.MinSKU' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $Assert.In($TargetObject, 'Properties.sku.name', @('Standard', 'Premium'));
    if ($TargetObject.Properties.sku.name -eq 'Standard') {
        $Assert.GreaterOrEqual($TargetObject, 'Properties.sku.capacity', 1);
    }
}

# Synopsis: Configure `maxmemory-reserved` to reserve memory for non-cache operations.
Rule 'Azure.Redis.MaxMemoryReserved' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    $sku = "$($TargetObject.Properties.sku.family)$($TargetObject.Properties.sku.capacity)";
    $memSize = (GetCacheMemory -Sku $sku) / 1MB;
    $Assert.GreaterOrEqual($TargetObject, 'Properties.redisConfiguration.maxmemory-reserved', $memSize * 0.1, $True);
}

# Synopsis: Premium Redis cache should be deployed with availability zones for high availability.
Rule 'Azure.Redis.AvailabilityZone' -Type 'Microsoft.Cache/Redis' -If { IsPremiumCache } -Tag @{ release = 'GA'; ruleSet = '2021_12'; } {
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
Rule 'Azure.RedisEnterprise.Zones' -Type 'Microsoft.Cache/redisEnterprise' -If { IsEnterpriseCache } -Tag @{ release = 'GA'; ruleSet = '2021_12'; } {
    $redisEnterpriseCacheProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Cache', 'redisEnterprise');

    $configurationZoneMappings = $Configuration.AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $redisEnterpriseCacheProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $locationAvailabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $locationAvailabilityZones) {
        return $Assert.Pass();
    }

    $capacityUnitMapping = @{
        'Enterprise' = @(2, 4, 6, 8, 10)
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

#endregion Helper functions
