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
    $resources = @($TargetObject.properties.template.resources);
    if ($resources.Length -eq 0 ) {
        return $Assert.Pass();
    }
    else {
        $propertyNames = $Configuration.GetStringValues('AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES');

        foreach ($resource in $resources) {
            foreach ($propertyName in $propertyNames) {
                $found = $PSRule.GetPath($resource, "$..$propertyName");
                if ($found -eq $Null -or $found.Length -eq 0) {
                    $Assert.Pass();
                }
                else {
                    Write-Debug "Found property name: $propertyName";
                    $Assert.Create(![PSRule.Rules.Azure.Runtime.Helper]::HasLiteralValue($found), $LocalizedData.LiteralSensitiveProperty, $propertyName);
                }
            }
        }
    }
}

# Synopsis: Ensure Outer scope deployments aren't using SecureString or SecureObject Parameters
Rule 'Azure.Deployment.OuterSecret' -Ref 'AZR-000313' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_12' } {
    
    if($TargetObject.properties.expressionEvaluationOptions.scope -eq 'Outer'){
        $cleanValue = [PSRule.Rules.Azure.Runtime.Helper]::CompressExpression($TargetObject);
        $Assert.NotMatch($cleanValue, '.', 'SecretReference');
    } else {
        $Assert.Pass()
    }
}


#endregion Rules
