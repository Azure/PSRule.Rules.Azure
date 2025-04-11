# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure deployments
#

#region Rules

# Synopsis: Avoid outputting sensitive deployment values.
Rule 'Azure.Deployment.OutputSecretValue' -Ref 'AZR-000279' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.Create($PSRule.Issue.Get('PSRule.Rules.Azure.Template.OutputSecretValue'));
}

# Synopsis: Ensure all properties named used for setting a username within a deployment are expressions (e.g. an ARM function not a string)
Rule 'Azure.Deployment.AdminUsername' -Ref 'AZR-000284' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } {
    RecurseDeploymentSensitive -Deployment $TargetObject
}

# Synopsis: Use secure parameters for any parameter that contains sensitive information.
Rule 'Azure.Deployment.SecureParameter' -Ref 'AZR-000408' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2023_12'; 'Azure.WAF/pillar' = 'Security'; } {
    GetSecureParameter -Deployment $TargetObject
}

# Synopsis: Use secure parameters for setting properties of resources that contain sensitive information.
Rule 'Azure.Deployment.SecureValue' -Ref 'AZR-000316' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2024_12'; 'Azure.WAF/pillar' = 'Security'; } {
    RecurseSecureValue -Deployment $TargetObject
}

# Synopsis: Ensure Outer scope deployments aren't using SecureString or SecureObject Parameters
Rule 'Azure.Deployment.OuterSecret' -Ref 'AZR-000331' -Type 'Microsoft.Resources/deployments' -If { IsParentDeployment } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $template = @($TargetObject.properties.template);
    if ($template.resources.Length -eq 0) {
        return $Assert.Pass();
    }

    $secureParameters = @($template.parameters.PSObject.properties | Where-Object {
            $_.Value.type -eq 'secureString' -or $_.Value.type -eq 'secureObject'
        } | ForEach-Object {
            $_.Name
        });
    foreach ($deployments in $template.resources) {
        if ($deployments.properties.expressionEvaluationOptions.scope -eq 'outer') {
            foreach ($outerDeployment in $deployments.properties.template.resources) {
                foreach ($property in $outerDeployment.properties) {
                    RecursivePropertiesSecretEvaluation -Resource $outerDeployment -SecureParameters $secureParameters -ShouldUseSecret $False -Property $property
                }
            }
        } else {
            $Assert.Pass()
        }
    }
}

# Synopsis: The deployment parameter leaks sensitive information.
Rule 'Azure.Deployment.SecretLeak' -Ref 'AZR-000459' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.Create($PSRule.Issue.Get('PSRule.Rules.Azure.Template.ParameterSecureAssignment'));
}

#endregion Rules

#region Helpers

function global:GetSecureParameter {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        $count = 0;
        if ($Null -ne $Deployment.properties.template.parameters.PSObject.properties) {
            foreach ($parameter in $Deployment.properties.template.parameters.PSObject.properties.GetEnumerator()) {
                if (
                    $Assert.Like($parameter, 'Name', @(
                        '*password*'
                        '*secret*'
                        '*token*'
                        '*key'
                        '*keys'
                    )).Result -and
                    $parameter.Name -ne 'customerManagedKey' -and
                    $parameter.Name -notLike '*name' -and
                    $parameter.Name -notLike '*uri' -and
                    $parameter.Name -notLike '*url' -and
                    $parameter.Name -notLike '*path' -and
                    $parameter.Name -notLike '*type' -and
                    $parameter.Name -notLike '*id' -and
                    $parameter.Name -notLike '*options' -and
                    $parameter.Name -notLike '*publickey' -and
                    $parameter.Name -notLike '*publickeys' -and
                    $parameter.Name -notLike '*secretname*' -and
                    $parameter.Name -notLike '*secreturl*' -and
                    $parameter.Name -notLike '*secreturi*' -and
                    $parameter.Name -notLike '*secrettype*' -and
                    $parameter.Name -notLike '*secretrotation*' -and
                    $parameter.Name -notLike '*tokenname*' -and
                    $parameter.Name -notLike '*tokentype*' -and
                    $parameter.Name -notLike '*interval*' -and
                    $parameter.Name -notLike '*length*' -and
                    $parameter.Name -notLike '*secretprovider*' -and
                    $parameter.Name -notLike '*secretsprovider*' -and
                    $parameter.Name -notLike '*secretref*' -and
                    $parameter.Name -notLike '*secretid*' -and
                    $parameter.Name -notLike '*disablepassword*' -and
                    $parameter.Name -notLike '*sync*passwords*' -and
                    $parameter.Name -notLike '*keyvaultpath*' -and
                    $parameter.Name -notLike '*keyvaultname*' -and
                    $parameter.Name -notLike '*keyvaulturi*' -and
                    $Assert.NotIn($parameter, 'Name', $Configuration.GetStringValues('AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES')).Result -and
                    $Null -ne $parameter.Value.type -and
                    $parameter.Value.type -ne 'bool' -and
                    $parameter.Value.type -ne 'int'
                ) {
                    $count++
                    $Assert.In($parameter.Value.type, '.', @('secureString', 'secureObject')).ReasonFrom($parameter.Name, $LocalizedData.InsecureParameterType, $parameter.Name, $parameter.Value.type);
                }
            }
        }
        if ($count -eq 0) {
            return $Assert.Pass();
        }
    }
}

function global:RecurseDeploymentSensitive {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        Write-Debug "Deployment is: $($Deployment.name)";
        $propertyNames = $Configuration.GetStringValues('AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES');

        # Resources could be an object or an array. Check if it is an object and enumerate properties instead.
        $resources = @($Deployment.properties.template.resources);
        if ($Deployment.properties.template.resources -is [System.Management.Automation.PSObject]) {
            $resources = @($Deployment.properties.template.resources.PSObject.Properties.GetEnumerator() | ForEach-Object {
                $_.Value
            });
        }

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
                        Write-Debug "Found property name: $propertyName, value: $found";
                        foreach ($value in $found) {
                            $Assert.Create(![PSRule.Rules.Azure.Runtime.Helper]::HasLiteralValue($value), $LocalizedData.LiteralSensitiveProperty, $propertyName);
                        }
                    }
                }
            }
        }
    }
}

function global:RecursivePropertiesSecretEvaluation {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [PSObject]$Property,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject]$SecureParameters,

        [Parameter(Mandatory = $False)]
        [Bool]$ShouldUseSecret = $True
    )
    process {
        $PropertyName = $Property.PSObject.properties.Name
        foreach ($NestedProperty in $Property.PSObject.Properties.Value.PSObject.Properties) {
            if($NestedProperty.MemberType -eq 'NoteProperty') {
                RecursivePropertiesSecretEvaluation -Resource $Resource -SecureParameters $SecureParameters -Property $NestedProperty -ShouldUseSecret $ShouldUseSecret
            } else {
                CheckPropertyUsesSecureParameter -Resource $Resource -SecureParameters $SecureParameters -PropertyPath "properties.$($PropertyName)" -ShouldUseSecret $ShouldUseSecret
            }
        }
    }
}

function global:CheckPropertyUsesSecureParameter {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject]$SecureParameters,

        [Parameter(Mandatory = $True)]
        [String]$PropertyPath,

        [Parameter(Mandatory = $False)]
        [Bool]$ShouldUseSecret = $True
    )
    process {
        $propertyValues = $PSRule.GetPath($Resource, $PropertyPath);
        if ($propertyValues.Length -eq 0) {
            return $Assert.Pass();
        }

        foreach ($propertyValue in $propertyValues) {
            $hasSecureParam = [PSRule.Rules.Azure.Runtime.Helper]::HasSecureValue($propertyValue, $SecureParameters);
            $Assert.Create($hasSecureParam -eq $ShouldUseSecret, $LocalizedData.SecureParameterRequired, $PropertyPath);
        }
    }
}

# Check resource properties that should be set by secure parameters.
function global:RecurseSecureValue {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        $resources = @($Deployment.properties.template.resources);
        if ($resources.Length -eq 0) {
            return $Assert.Pass();
        }

        $secureParameters = @($Deployment.properties.template.parameters.PSObject.properties | Where-Object {
                $_.Value.type -eq 'secureString' -or $_.Value.type -eq 'secureObject'
            } | ForEach-Object {
                $_.Name
            });
        Write-Debug -Message "Secure parameters are: $($secureParameters -join ', ')";

        foreach ($resource in $resources) {
            if ($resource.type -eq 'Microsoft.Resources/Deployments') {
                RecurseSecureValue -Deployment $resource;
            }
            else {
                $properties = [PSRule.Rules.Azure.Runtime.Helper]::GetSecretProperty($PSRule.GetService('Azure.Context'), $resource.type);
                if ($Null -eq $properties -or $properties.Length -eq 0) {
                    $Assert.Pass();
                }
                else {
                    foreach ($property in $properties) {
                        CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath $property
                    }
                }
            }
        }
    }
}


# Check if the TargetObject is a parent deployment, with scoped deployments or a rendered deployment
function global:IsParentDeployment {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        foreach ($deployment in $TargetObject.properties.template.resources){
            return $Assert.HasField($deployment, 'properties.expressionEvaluationOptions.scope').Result;
        }
    }
}

#endregion Helpers
