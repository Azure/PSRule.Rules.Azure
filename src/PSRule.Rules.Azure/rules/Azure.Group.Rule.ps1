# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Resource Groups
#

# Synopsis: Use standard resource groups names.
Rule 'Azure.Group.Naming' -Ref 'AZR-000464' -Type 'Microsoft.Resources/resourceGroups' -If { !(Azure_IsManagedRG) -and $Configuration['AZURE_RESOURCE_GROUP_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_RESOURCE_GROUP_NAME_FORMAT, $True);
}

# # Synopsis: Tag resource groups with mandatory tags.
# Rule 'Azure.Group.RequiredTags' -Ref 'AZR-000nnn' -Type 'Microsoft.Resources/resourceGroups' -If { ($Configuration.GetStringValues('CAF_ResourceGroupMandatoryTags').Length -gt 0) } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'tagging' } {
#     $required = $Configuration.GetStringValues('CAF_ResourceGroupMandatoryTags');
#     if ($required.Length -eq 0) {
#         return $Assert.Pass();
#     }
#     $Assert.HasField($TargetObject, 'tags');
#     if ($Null -ne $TargetObject.Tags) {
#         $Assert.HasFields($TargetObject.Tags, $required, $Configuration.CAF_MatchTagNameCase);
#     }
# }
