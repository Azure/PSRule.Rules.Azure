# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Resource Groups
#

# Synopsis: Use standard resource groups names.
Rule 'Azure.Group.Naming' -Ref 'AZR-000464' -Type 'Microsoft.Resources/resourceGroups' -If { !(Azure_IsManagedRG) -and $Configuration['AZURE_RESOURCE_GROUP_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_RESOURCE_GROUP_NAME_FORMAT, $True);
}

# Synopsis: Tag resource groups with mandatory tags.
Rule 'Azure.Group.RequiredTags' -Ref 'AZR-000478' -Type 'Microsoft.Resources/resourceGroups' -If { $Configuration.GetStringValues('AZURE_RESOURCE_GROUP_REQUIRED_TAGS').Length -gt 0 } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
    $required = $Configuration.GetStringValues('AZURE_RESOURCE_GROUP_REQUIRED_TAGS')
    if ($required.Length -eq 0) {
        return $Assert.Pass();
    }

    # Check that the tag exists.
    if (!$Assert.HasField($PSRule.TargetObject, 'tags', $False).Result) {
        return $Assert.Fail($LocalizedData.ResourceHasNoTags, [String]::Join(', ', $required)).PathPrefix('tags');
    }
    $Assert.HasFields($PSRule.TargetObject.tags, $required, $True);

    # Check for required name format.
    foreach ($tagName in $required) {
        Write-Verbose "Check tag format for $tagName"
        $requiredValueFormat = $Configuration.GetValueOrDefault("AZURE_TAG_FORMAT_FOR_$($tagName.ToUpper())", $Null)
        if (![String]::IsNullOrWhiteSpace($requiredValueFormat)) {
            Write-Verbose "Check tag format for $tagName`: $requiredValueFormat"
            $Assert.Match($PSRule.TargetObject, "tags.$tagName", $requiredValueFormat, $True);
        }
    }
}
