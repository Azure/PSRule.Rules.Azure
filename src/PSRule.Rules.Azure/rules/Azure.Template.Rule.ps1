# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure template and parameter files
#

#region Template

# Synopsis: Use ARM template file structure.
Rule 'Azure.Template.TemplateFile' -Type 'System.IO.FileInfo','.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $jsonObject | Exists '$schema', 'contentVersion', 'resources' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters', 'functions', 'variables', 'resources', 'outputs'
}

# Synopsis: Use template parameter descriptions.
Rule 'Azure.Template.ParameterMetadata' -Type 'System.IO.FileInfo','.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $parameters = @($jsonObject.parameters.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' });
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.
            HasFieldValue($parameter.value, 'metadata.description').
            Reason($LocalizedData.TemplateParameterDescription, $parameter.name);
    }
}

# Synopsis: ARM templates should include at least one resource.
Rule 'Azure.Template.Resources' -Type 'System.IO.FileInfo','.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $Assert.GreaterOrEqual($jsonObject, 'resources', 1);
}

# Synopsis: ARM template parameters should be used at least once.
Rule 'Azure.Template.UseParameters' -Type 'System.IO.FileInfo','.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $jsonContent = Get-Content -Path $TargetObject.FullName -Raw;
    $parameters = @($jsonObject.parameters.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' });
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.
            Match($jsonContent, '.', "\`"\[.*parameters\(\s{0,}'$($parameter.name)'\s{0,}\).*\]\`"").
            Reason($LocalizedData.ParameterNotFound, $parameter.name);
    }
}

# Synopsis: ARM template variables should be used at least once.
Rule 'Azure.Template.UseVariables' -Type 'System.IO.FileInfo','.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $jsonContent = Get-Content -Path $TargetObject.FullName -Raw;
    $variableNames = @($jsonObject.variables.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' } | ForEach-Object {
        $variable = $_;
        if ($variable.name -eq 'copy') {
            $variable.value | ForEach-Object {
                $_.name;
            }
        }
        else {
            $variable.name;
        }
    });
    if ($variableNames.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($variableName in $variableNames) {
        $Assert.
            Match($jsonContent, '.', "\`"\[.*variables\(\s{0,}'$($variableName)'\s{0,}\).*\]\`"").
            Reason($LocalizedData.VariableNotFound, $variableName);
    }
}

#endregion Template

#region Parameters

# Synopsis: Use ARM parameter file structure.
Rule 'Azure.Template.ParameterFile' -Type 'System.IO.FileInfo','.json' -If { (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $jsonObject = ReadJsonFile -Path $TargetObject.FullName;
    $jsonObject | Exists '$schema', 'contentVersion', 'parameters' -All
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters'
}

#endregion Parameters

#region Helper functions

# Determines if the object is a Azure Resource Manager template file
function global:IsTemplateFile {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $False)]
        [String]$Suffix
    )
    process {
        if ($TargetObject.Extension -ne '.json') {
            return $False;
        }
        try {
            $jsonObject = Get-Content -Path $TargetObject.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue;
            [String]$targetSchema = $jsonObject.'$schema';
            $schemas = @(
                # Https
                "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json`#"
                "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json`#"
                "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json`#"
                "https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json`#"
                "https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json`#"

                # Http
                "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json`#"
                "http://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json`#"
                "http://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json`#"
                "http://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json`#"
                "http://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json`#"
            )
            return $targetSchema -in $schemas -and ([String]::IsNullOrEmpty($Suffix) -or $targetSchema.EndsWith($Suffix));
        }
        catch {
            return $False;
        }
    }
}

# Determines if the object is a Azure Resource Manager parameter file
function global:IsParameterFile {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($TargetObject.Extension -ne '.json') {
            return $False;
        }
        try {
            $jsonObject = Get-Content -Path $TargetObject.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue;
            $schemas = @(
                # Https
                "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"

                # Http
                "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
                "http://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
            )
            return $jsonObject.'$schema' -in $schemas;
        }
        catch {
            return $False;
        }
    }
}

# Read a file as JSON
function global:ReadJsonFile {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )
    process {
        # return $PSRule.GetContent([System.IO.FileInfo]$Path);
        return Get-Content -Path $TargetObject.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue;
    }
}

#endregion Helper functions
