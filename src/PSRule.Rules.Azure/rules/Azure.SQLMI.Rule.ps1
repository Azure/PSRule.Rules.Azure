# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure SQL Managed Instance
#

#region SQL Managed Instance

# Synopsis: SQL Managed Instance names should meet naming requirements.
Rule 'Azure.SQLMI.Name' -Ref 'AZR-000194' -Type 'Microsoft.Sql/managedInstances' -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

# Synopsis: Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance.
Rule 'Azure.SQLMI.AADOnly' -Ref 'AZR-000366' -Type 'Microsoft.Sql/managedInstances', 'Microsoft.Sql/managedInstances/azureADOnlyAuthentications' -Tag @{ release = 'GA'; ruleSet = '2023_03'; 'Azure.WAF/pillar' = 'Security'; } {
    $types = 'Microsoft.Sql/managedInstances', 'Microsoft.Sql/managedInstances/azureADOnlyAuthentications'
    $enabledAADOnly = @(GetAzureSQLADOnlyAuthentication -ResourceType $types | Where-Object { $_ })
    $Assert.GreaterOrEqual($enabledAADOnly, '.', 1).Reason($LocalizedData.AzureADOnlyAuthentication)
}

# Synopsis: Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instances.
Rule 'Azure.SQLMI.AAD' -Ref 'AZR-000368' -Type 'Microsoft.Sql/managedInstances', 'Microsoft.Sql/managedInstances/administrators' -Tag @{ release = 'GA'; ruleSet = '2023_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1' } {
    # NB: Microsoft.Sql/managedInstances/administrators overrides properties.administrators property.
    if ($PSRule.TargetType -eq 'Microsoft.Sql/managedInstances') {
        $configs = @(GetSubResources -ResourceType 'Microsoft.Sql/managedInstances/administrators' -Name 'ActiveDirectory')

        if ($configs.Length -eq 0 -and $PSRule.TargetType -eq 'Microsoft.Sql/managedInstances') {
            $Assert.HasFieldValue($TargetObject, 'properties.administrators.administratorType', 'ActiveDirectory')
            $Assert.HasFieldValue($TargetObject, 'properties.administrators.login')
            $Assert.HasFieldValue($TargetObject, 'properties.administrators.sid') 
        }
        else {
            foreach ($config in $configs) {
                $Assert.HasFieldValue($config, 'properties.administratorType', 'ActiveDirectory')
                $Assert.HasFieldValue($config, 'properties.login')
                $Assert.HasFieldValue($config, 'properties.sid')
            }
        }
    }
    else {
        $Assert.HasFieldValue($TargetObject, 'properties.administratorType', 'ActiveDirectory')
        $Assert.HasFieldValue($TargetObject, 'properties.login')
        $Assert.HasFieldValue($TargetObject, 'properties.sid')
    }
}

#endregion SQL Managed Instance
