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


# Synopsis: Ensure all properties named used for setting a username within a deployment are expressions (e.g. an ARM function not a string)
Rule 'Azure.Deployment.AdminUsername' -Ref 'AZR-000284' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_09' } {  
    $deploymentTemplate = @($TargetObject.properties.template);

    if (($deploymentTemplate.resources).Length -eq 0 ) {
        return $Assert.Pass();
    } else {
        foreach ($resource in $deploymentTemplate.resources.properties) {
            global:FindAdminUsername -InputObject $resource
        }
    }
}

## Functions
function global:FindAdminUsername {
    param ([PSObject]$InputObject)
    process {
    foreach ($property in $InputObject.PSObject.properties) {
        ## Loop again if the property is a nested object
        if($property.Value.GetType().Name -eq 'PSCustomObject') {
            foreach($nestedProperty in $property.Value.PSObject.Properties ){
                global:CheckSensitiveProperties -InputObject $nestedProperty
            }
        } elseif ($property.value.GetType().Name -eq 'String') {
            global:CheckSensitiveProperties -InputObject $property
        } 
      }
    }
  }

  function global:CheckSensitiveProperties {
    param (
        [PSObject]$InputObject
        )
    process {
        if ($Configuration.GetStringValues('AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES') -contains $InputObject.Name) {
            $cleanValue = [PSRule.Rules.Azure.Runtime.Helper]::CompressExpression($InputObject.Value);
            $Assert.Match($cleanValue, '.', '\[p[^\]]+\]')   
        } else {
            $Assert.Pass()
        }
    }
  }