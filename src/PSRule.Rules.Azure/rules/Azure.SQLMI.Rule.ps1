# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure SQL Managed Instance
#

#region SQL Managed Instance

# Synopsis: SQL Managed Instance names should meet naming requirements.
Rule 'Azure.SQLMI.Name' -Type 'Microsoft.Sql/managedInstances' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftsql

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Lowercase letters, numbers, and hyphens
    # Can't start or end with a hyphen
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]([a-z0-9-]*[a-z0-9]){0,62}$', $True);
}

#endregion SQL Managed Instance