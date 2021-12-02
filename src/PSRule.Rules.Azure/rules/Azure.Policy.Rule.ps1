# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Policy
#

# Synopsis: Policy and initiative definitions require a display name, description, and category.
Rule 'Azure.Policy.Descriptors' -Type 'Microsoft.Authorization/policyDefinitions', 'Microsoft.Authorization/policySetDefinitions' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'properties.displayName');
    $Assert.HasFieldValue($TargetObject, 'properties.description');
    $Assert.HasFieldValue($TargetObject, 'properties.metadata.category');
}

# Synopsis: Policy assignments require a display name and description.
Rule 'Azure.Policy.AssignmentDescriptors' -Type 'Microsoft.Authorization/policyAssignments' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.displayName');
    $Assert.HasFieldValue($TargetObject, 'properties.description');
}

# Synopsis: Policy assignments require assignedBy metadata.
Rule 'Azure.Policy.AssignmentAssignedBy' -Type 'Microsoft.Authorization/policyAssignments' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.metadata.assignedBy');
}

# Synopsis: Policy exemptions require a display name, and description.
Rule 'Azure.Policy.ExemptionDescriptors' -Type 'Microsoft.Authorization/policyExemptions' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.displayName');
    $Assert.HasFieldValue($TargetObject, 'properties.description');
}

# Synopsis: Policy exceptions must be less then 2 years.
Rule 'Azure.Policy.WaiverExpiry' -Type 'Microsoft.Authorization/policyExemptions' -With 'Azure.PolicyExemptionWaiver' -Tag @{ release = 'GA'; ruleSet = '2021_06' } {
    $Assert.LessOrEqual($TargetObject, 'properties.expiresOn', $Configuration.AZURE_POLICY_WAIVER_MAX_EXPIRY);
} -Configure @{ AZURE_POLICY_WAIVER_MAX_EXPIRY = 366 }
