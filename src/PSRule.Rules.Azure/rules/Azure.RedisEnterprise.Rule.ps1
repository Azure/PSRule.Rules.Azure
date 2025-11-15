# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Managed Redis (Redis Enterprise)
#

#region Naming rules

# Synopsis: Azure Managed Redis instances without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.RedisEnterprise.Naming' -Ref 'AZR-000524' -Type 'Microsoft.Cache/RedisEnterprise' -If { $Configuration['AZURE_REDIS_ENTERPRISE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_REDIS_ENTERPRISE_NAME_FORMAT, $True);
}

#endregion Naming rules
