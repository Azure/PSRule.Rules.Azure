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

# Synopsis: Use secure parameters for setting properties of resources that contain sensitive information.
Rule 'Azure.Deployment.SecureValue' -Ref 'AZR-000314' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    RecurseSecureValue -Deployment $TargetObject
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

function global:CheckPropertyUsesSecureParameter {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject]$SecureParameters,

        [Parameter(Mandatory = $True)]
        [String]$PropertyPath
    )
    process {
        $propertiesInPath = $PropertyPath.Split(".")
        $propertyValue = $Resource
        foreach($aPropertyInThePath in $propertiesInPath) {
            $propertyValue = $propertyValue."$aPropertyInThePath"
        }

        if ($propertyValue) {
            $isSecure = [PSRule.Rules.Azure.Runtime.Helper]::HasValueFromSecureParameter($propertyValue, $SecureParameters);
            $Assert.Create($isSecure).Reason($LocalizedData.SecureParameterRequired, $PropertyPath);
        }
        else {
            $Assert.Pass();
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
            switch ($resource.type)
            {
                'Microsoft.Resources/deployments' { 
                    RecurseSecureValue -Deployment $resource;
                }
                'Microsoft.Compute/virtualMachineScaleSets' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.virtualMachineProfile.osProfile.adminPassword'
                }
                'Microsoft.KeyVault/vaults/secrets' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.value'
                }
                Default {
                    $Assert.Pass();
                }
            }
        }
    }
}

#endregion Helpers