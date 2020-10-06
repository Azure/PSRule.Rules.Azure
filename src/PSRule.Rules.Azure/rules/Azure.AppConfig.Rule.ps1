# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Configuration
#

# Synopsis: App Configuration should use a minimum size of Standard.
Rule 'Azure.AppConfig.SKU' -Type 'Microsoft.AppConfiguration/configurationStores' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    $Assert.HasFieldValue($TargetObject, 'Sku.Name', 'standard');
}

# Synopsis: App Configuration store names should meet naming requirements.
Rule 'Azure.AppConfig.Name' -Type 'Microsoft.AppConfiguration/configurationStores' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    # Between 5 and 50 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 5)
    $Assert.LessOrEqual($PSRule, 'TargetName', 50)

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z0-9](-|[A-Za-z0-9]){3,48}[A-Za-z0-9]$')
}
