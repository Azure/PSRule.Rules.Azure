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

# # Synopsis: Tag resources and resource groups with a valid environment.
# Rule 'Azure.Resource.Environment' -Ref 'AZR-000nnn' -With 'Azure.Resource.SupportsTags' -If { (Exists "tags.$($Configuration.CAF_EnvironmentTag)") } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
#     $Assert.HasField($TargetObject, 'tags');
#     if ($Null -ne $TargetObject.Tags) {
#         $Assert.HasField($TargetObject.Tags, $Configuration.CAF_EnvironmentTag, $Configuration.CAF_MatchTagNameCase);
#         $Assert.In($TargetObject.Tags, $Configuration.CAF_EnvironmentTag, $Configuration.CAF_Environments, $Configuration.CAF_MatchTagValueCase);
#     }
# }

# # Synopsis: Tag resources with mandatory tags.
# Rule 'CAF.Tag.Resource' -Ref 'AZR-000nnn' -With 'Azure.Resource.SupportsTags' -If { !($PSRule.TargetType -eq 'Microsoft.Resources/resourceGroups') -and ($Configuration.GetStringValues('CAF_ResourceMandatoryTags').Length -gt 0) } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
#     $required = $Configuration.GetStringValues('CAF_ResourceMandatoryTags')
#     if ($required.Length -eq 0) {
#         return $Assert.Pass();
#     }
#     $Assert.HasField($TargetObject, 'tags');
#     if ($Null -ne $TargetObject.Tags) {
#         $Assert.HasFields($TargetObject.Tags, $required, $Configuration.CAF_MatchTagNameCase);
#     }
# }
