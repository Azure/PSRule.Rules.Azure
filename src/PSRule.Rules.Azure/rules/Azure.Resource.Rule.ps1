# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure resources
#

if ($Null -ne $Configuration.azureAllowedRegions) {
    Write-Warning -Message ($LocalizedData.ConfigurationOptionReplaced -f 'azureAllowedRegions', 'Azure_AllowedRegions');
}

# Synopsis: Resources should be tagged
Rule 'Azure.Resource.UseTags' -If { SupportsTags } -Tag @{ release = 'GA' } {
    Reason $LocalizedData.ResourceNotTagged
    # List of resource that support tags can be found here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/tag-support
    (Exists 'Tags') -and
    (($TargetObject.Tags.PSObject.Members | Where-Object { $_.MemberType -eq 'NoteProperty' }) -ne $Null)
}

# Synopsis: Resources should be deployed to allowed regions
Rule 'Azure.Resource.AllowedRegions' -If { ($Null -ne $Configuration.Azure_AllowedRegions) -and ($Configuration.Azure_AllowedRegions.Length -gt 0) -and (SupportsRegions) } -Tag @{ release = 'GA' } {
    IsAllowedRegion
}
