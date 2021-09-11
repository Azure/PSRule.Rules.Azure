# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Cosmos DB
#

# Synopsis: Cosmos DB account names should meet naming requirements.
Rule 'Azure.Cosmos.AccountName' -Type 'Microsoft.DocumentDb/databaseAccounts' -Tag @{ release = 'GA'; ruleSet = '2021_09' } {
    # Between 3 and 33 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3)
    $Assert.LessOrEqual($PSRule, 'TargetName', 44)

    # Lowercase letters, numbers, and hyphens
    # Start and end with lettings and numbers
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9](-|[a-z0-9]){1,41}[a-z0-9]$');
}
