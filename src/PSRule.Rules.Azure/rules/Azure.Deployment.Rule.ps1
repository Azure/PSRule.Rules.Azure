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

# Synopsis: Ensure Outer scope deployments aren't using SecureString or SecureObject Parameters
Rule 'Azure.Deployment.OuterSecret' -Ref 'AZR-000314' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_12' } { 

    $template = @($TargetObject.properties.template);
    if ($template.resources.Length -eq 0) {
        return $Assert.Pass();
    }

    $secureParameters = @($template.parameters.PSObject.properties | Where-Object {
        $_.Value.type -eq 'secureString' -or $_.Value.type -eq 'secureObject'
    } | ForEach-Object {
        $_.Name
    });
    Write-Host -Message "Secure parameters are: $($secureParameters -join ', ')";

    foreach ($deployments in $template.resources) {
        if ($deployments.properties.expressionEvaluationOptions.scope -eq 'outer') {
            foreach ($outerDeployment in $deployments.properties.template.resources) {
                if ($outerDeployment.properties.psobject.properties.count -gt 0) {
                    Write-Host "Name $($Deployments.name)"
                    foreach ($property in $outerDeployment.properties) {
                        Write-Host "Property: $property"
                        if ($property.GetType().Name -eq "PSCustomObject") { 
                            foreach($nestedProperty in $property.PSObject.Properties.Value.PSObject.Properties ){
                                Write-Host "NestedProp: $nestedProperty"
                                Write-Host "nestedprop value: $($nestedProperty.Value)"
                                CheckPropertyUsesSecureParameter -SecureParameters $SecureParameters -Property $nestedProperty.Value
                            } 
                        }
                        elseif ($property.GetType().Name -eq "String") {
                            Write-Host "String: $property"
                        }
                    }
                } else {
                    $Assert.Pass()
                }
                
            }
        } 
    }
    
}


#endregion Rules

function global:CheckPropertyUsesSecureParameter {
    param (
        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject]$SecureParameters,

        [Parameter(Mandatory = $True)]
        [String]$Property
    )
    process {

        if($Property){
            
            $hasSecureParameter = [PSRule.Rules.Azure.Runtime.Helper]::HasSecureValue($Property, $SecureParameters);
            Write-Host "propertyValue: $Property"
            Write-Host "SecureParameters: $SecureParameters"
            Write-Host "isSecure: $hasSecureParameter"
            $Assert.Create($hasSecureParameter).Reason($LocalizedData.SecureParameterRequired, $Property);
        } else {
            $Assert.Pass();
        }
        
        
    }
}