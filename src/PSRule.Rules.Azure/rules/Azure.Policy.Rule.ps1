# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Policy
#

# Synopsis: Policy and initiative definitions require display name, description and category set
Rule 'Azure.Policy.Descriptors' -Type 'Microsoft.Authorization/policyDefinitions', 'Microsoft.Authorization/policySetDefinitions' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'properties.displayName');
    $Assert.HasFieldValue($TargetObject, 'properties.description');
    $Assert.HasFieldValue($TargetObject, 'properties.metadata.category');
}
