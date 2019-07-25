#
# Validation rules for Azure resources
#

if ($Null -eq $Configuration.azureAllowedRegions) {
    Write-Warning -Message 'The azureAllowedRegions option is not configured';
}

# Synopsis: Resources should be tagged
Rule 'Azure.Resource.UseTags' -If { (SupportsTags) } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Reason $LocalizedData.ResourceNotTagged
    # List of resource that support tags can be found here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/tag-support
    (Exists 'Tags') -and
    (($TargetObject.Tags.PSObject.Members | Where-Object { $_.MemberType -eq 'NoteProperty' }) -ne $Null)
}

# Synopsis: Resources should be deployed to allowed regions
Rule 'Azure.Resource.AllowedRegions' -If { ($Null -ne $Configuration.azureAllowedRegions) -and (SupportsRegions) } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    IsAllowedRegion
}
