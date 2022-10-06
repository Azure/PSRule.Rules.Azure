# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure deployments
#

#region Rules

# Synopsis: Avoid outputting sensitive deployment values.
Rule 'Azure.Deployment.OutputSecretValue' -Ref 'AZR-000279' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_06'; } {
    $Assert.Create($PSRule.Issue.Get('PSRule.Rules.Azure.Template.OutputSecretValue'));
}

# Synopsis: Ensure all properties named used for setting a username within a deployment are expressions (e.g. an ARM function not a string)
Rule 'Azure.Deployment.AdminUsername' -Ref 'AZR-000284' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_09' } {
    RecurseDeploymentSensitive -Deployment $TargetObject
}

#endregion Rules

#region Helpers

function global:RecurseDeploymentSensitive {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        $propertyNames = $Configuration.GetStringValues('AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES');
        $resources = @($Deployment.properties.template.resources);
        if ($resources.Length -eq 0) {
            return $Assert.Pass();
        }

        foreach ($resource in $resources) {
            if ($resource.type -eq 'Microsoft.Resources/deployments') {
                RecurseDeploymentSensitive -Deployment $resource;
            }
            else {
                foreach ($propertyName in $propertyNames) {
                    $found = $PSRule.GetPath($resource, "$..$propertyName");
                    if ($Null -eq $found -or $found.Length -eq 0) {
                        $Assert.Pass();
                    }
                    else {
                        Write-Debug "Found property name: $propertyName";
                        foreach ($value in $found) {
                            $Assert.Create(![PSRule.Rules.Azure.Runtime.Helper]::HasLiteralValue($value), $LocalizedData.LiteralSensitiveProperty, $propertyName);
                        }
                    }
                }
            }
        }
    }
}

#endregion Helpers
