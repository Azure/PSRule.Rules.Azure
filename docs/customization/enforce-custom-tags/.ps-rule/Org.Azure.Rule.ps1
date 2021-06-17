# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for validation of Azure resource groups
#

# Synopsis: Resource Groups must have all mandatory tags defined.
Rule 'Org.Azure.RG.Tags' -Type 'Microsoft.Resources/resourceGroups' {
    $hasTags = $Assert.HasField($TargetObject, 'Tags')
    if (!$hasTags.Result) {
        return $hasTags
    }

    # Require tags be case-sensitive.
    $Assert.HasField($TargetObject.tags, 'costCentre', <# case-sensitive #> $True)
    $Assert.HasField($TargetObject.tags, 'env', $True)

    <#
    The costCentre tag must:
    - Start with a letter.
    - Be followed by a number between 10000-9999999999.
    #>
    $Assert.Match($TargetObject, 'tags.costCentre', '^([A-Z][1-9][0-9]{4,9})$', $True)

    # Require specific values for environment tag.
    $Assert.In($TargetObject, 'tags.env', @(
        'dev',
        'prod',
        'uat'
    ), $True)
}
