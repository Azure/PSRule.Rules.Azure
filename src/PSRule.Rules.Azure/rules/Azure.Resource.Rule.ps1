# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure resources
#

# Synopsis: Resources should be tagged
Rule 'Azure.Resource.UseTags' -Ref 'AZR-000166' -With 'Azure.Resource.SupportsTags' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    Reason $LocalizedData.ResourceNotTagged
    # List of resource that support tags can be found here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/tag-support
    $Assert.HasField($TargetObject, 'tags')
    $Assert.Create(($TargetObject.Tags.PSObject.Members | Where-Object { $_.MemberType -eq 'NoteProperty' }) -ne $Null)
}

# Synopsis: Resources should be deployed to allowed regions
Rule 'Azure.Resource.AllowedRegions' -Ref 'AZR-000167' -If { ($Null -ne $Configuration.Azure_AllowedRegions) -and ($Configuration.Azure_AllowedRegions.Length -gt 0) -and (SupportsRegions) -and $PSRule.TargetType -ne 'Microsoft.Resources/deployments' } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $region = @($Configuration.Azure_AllowedRegions);
    foreach ($r in $Configuration.Azure_AllowedRegions) {
        $region += ($r -replace ' ', '')
    }
    $Assert.In($TargetObject, 'location', $region);
}

# Synopsis: Use Resource Group naming requirements
Rule 'Azure.ResourceGroup.Name' -Ref 'AZR-000168' -Type 'Microsoft.Resources/resourceGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftresources

    # Between 1 and 90 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 90);

    # Alphanumerics, underscores, parentheses, hyphens, periods
    # Can't end with period.
    $Assert.Match($PSRule, 'TargetName', '^[-\w\._\(\)]*[-\w_\(\)]$');
}


# Synopsis: Ensure all properties named `adminUsername` within a deployment are expressions (not literal strings)
Rule 'Azure.Resource.adminUsername' -Ref 'AZR-000280' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_06' } {  
    $deploymentResources = @($TargetObject.properties.template.resources);

    if ($deploymentResources.Length -eq 0 ) {
        return $Assert.Pass();
    } 

    foreach ($resource in $deploymentResources) {
        global:FindAdminUsername -InputObject $resource

        # 

    }
    
}

## Functions
function global:FindAdminUsername {
    param ([PSObject]$InputObject)
    process {
      foreach ($property in $InputObject.PSObject.properties) {
        if ($property.Name -eq 'adminUsername' ) {
          Write-Output "Found adminUsername" 
          return $Assert.Pass();
        }
        # elseif ($property.Value -is [PSObject]) {
        #     Write-Output "Didn't find adminUsername"
        # }
      }
    }
  }