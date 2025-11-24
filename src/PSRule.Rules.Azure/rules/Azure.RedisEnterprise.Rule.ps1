# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Redis Enterprise Cache
#

# Synopsis: Azure Cache for Redis Enterprise and Enterprise Flash are being retired. Migrate to Azure Managed Redis.
Rule 'Azure.RedisEnterprise.MigrateAMR' -Ref 'AZR-000534' -Type 'Microsoft.Cache/redisEnterprise' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.Fail($LocalizedData.RedisEnterpriseMigrateAMR)
}
