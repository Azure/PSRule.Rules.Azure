# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cache for Redis Enterprise and Enterprise Flash
#

# Synopsis: Azure Cache for Redis Enterprise and Enterprise Flash are being retired. Migrate to Azure Managed Redis.
Rule 'Azure.RedisEnterprise.MigrateAMR' -Ref 'AZR-000534' -Type 'Microsoft.Cache/redisEnterprise' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $deprecatedSkus = @(
        'Enterprise_E1',
        'Enterprise_E5',
        'Enterprise_E10',
        'Enterprise_E20',
        'Enterprise_E50',
        'Enterprise_E100',
        'Enterprise_E200',
        'Enterprise_E400',
        'EnterpriseFlash_F300',
        'EnterpriseFlash_F700',
        'EnterpriseFlash_F1500'
    )
    $Assert.NotIn($TargetObject, 'sku.name', $deprecatedSkus).Reason($LocalizedData.RedisEnterpriseMigrateAMR)
}
