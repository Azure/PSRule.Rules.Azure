# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Data Factory
#

# Synopsis: Consider migrating to DataFactory v2
Rule 'Azure.DataFactory.Version' -Type 'Microsoft.DataFactory/datafactories', 'Microsoft.DataFactory/factories' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($PSRule.TargetType, '.', 'Microsoft.DataFactory/factories');
}
