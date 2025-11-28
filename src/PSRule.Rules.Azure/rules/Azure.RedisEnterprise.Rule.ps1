# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cache for Redis Enterprise and Enterprise Flash
#

#region Naming rules

# Synopsis: Azure Managed Redis instances without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.RedisEnterprise.Naming' -Ref 'AZR-000524' -Type 'Microsoft.Cache/RedisEnterprise' -With 'Azure.Redis.IsEnterprise' -If { $Configuration['AZURE_REDIS_ENTERPRISE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_REDIS_ENTERPRISE_NAME_FORMAT, $True);
}

#endregion Naming rules

# Synopsis: Azure Cache for Redis Enterprise and Enterprise Flash are being retired. Migrate to Azure Managed Redis.
Rule 'Azure.RedisEnterprise.MigrateAMR' -Ref 'AZR-000534' -Type 'Microsoft.Cache/redisEnterprise' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.NotLike($TargetObject, 'sku.name', @('Enterprise_*', 'EnterpriseFlash_*')).Reason($LocalizedData.RedisEnterpriseMigrateAMR)
}
