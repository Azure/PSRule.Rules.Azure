# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure resources
#

# Synopsis: Azure resources should be tagged using a standard convention.
Rule 'Azure.Resource.UseTags' -Ref 'AZR-000166' -With 'Azure.Resource.SupportsTags' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    Reason $LocalizedData.ResourceNotTagged
    # List of resource that support tags can be found here: https://learn.microsoft.com/en-us/azure/azure-resource-manager/tag-support
    $Assert.HasField($TargetObject, 'tags')
    $Assert.Create(($TargetObject.Tags.PSObject.Members | Where-Object { $_.MemberType -eq 'NoteProperty' }) -ne $Null)
}

# Synopsis: Resources should be deployed to allowed regions.
Rule 'Azure.Resource.AllowedRegions' -Ref 'AZR-000167' -If { (SupportsRegions) -and $PSRule.TargetType -ne 'Microsoft.Resources/deployments' -and $Assert.HasFieldValue($TargetObject, 'location').Result } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $context = $PSRule.GetService('Azure.Context');
    $location = $TargetObject.location;
    $Assert.Create('location', [bool]$context.IsAllowedLocation($location), $LocalizedData.LocationNotAllowed, @($location));
}

# Synopsis: Tag resources with mandatory tags.
Rule 'Azure.Resource.RequiredTags' -Ref 'AZR-000477' -With 'Azure.Resource.SupportsTags' -If { !($PSRule.TargetType -eq 'Microsoft.Resources/resourceGroups') -and ($Configuration.GetStringValues('AZURE_RESOURCE_REQUIRED_TAGS').Length -gt 0) } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
    $required = $Configuration.GetStringValues('AZURE_RESOURCE_REQUIRED_TAGS')
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
        $requiredValueFormat = $Configuration.GetValueOrDefault("AZURE_TAG_FORMAT_FOR_$($tagName.ToUpper())", $Null)
        if (![String]::IsNullOrWhiteSpace($requiredValueFormat)) {
            $Assert.Match($PSRule.TargetObject, "tags.$tagName", $requiredValueFormat, $True);
        }
    }
}
