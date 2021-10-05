# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure template and parameter files
#

#region Template

# Synopsis: Use ARM template file structure.
Rule 'Azure.Template.TemplateFile' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $Assert.HasFields($jsonObject, @('$schema', 'contentVersion', 'resources'));
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters', 'functions', 'variables', 'resources', 'outputs';
}

# Synopsis: Use a more recent version of the Azure template schema.
Rule 'Azure.Template.TemplateSchema' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $Assert.HasJsonSchema($jsonObject, @(
        'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json'
        'https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json'
        'https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json'
        'https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json'
    ), $True);
}

# Synopsis: Use a Azure template schema with the https scheme.
Rule 'Azure.Template.TemplateScheme' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $Assert.StartsWith($jsonObject, '$schema', 'https://');
}

# Synopsis: Use template parameter descriptions.
Rule 'Azure.Template.ParameterMetadata' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $parameters = @(GetTemplateParameters);
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.HasFieldValue($parameter.value, 'metadata.description').
            Reason($LocalizedData.TemplateParameterDescription, $parameter.name);
    }
}

# Synopsis: ARM templates should include at least one resource.
Rule 'Azure.Template.Resources' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = $PSRule.GetContent($TargetObject)[0];
    $Assert.GreaterOrEqual($jsonObject, 'resources', 1);
}

# Synopsis: ARM template parameters should be used at least once.
Rule 'Azure.Template.UseParameters' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonContent = Get-Content -Path $TargetObject.FullName -Raw;
    $parameters = @(GetTemplateParameters);
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.Match($jsonContent, '.', "\`"\[[\s\S]*parameters\(\s{0,}'$($parameter.name.Replace('$', '\$'))'\s{0,}\)[\s\S]*\]\`"").
            Reason($LocalizedData.ParameterNotFound, $parameter.name);
    }
}

# Synopsis: Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters.
Rule 'Azure.Template.DefineParameters' -Type '.json' -If { (IsTemplateFile) -and !(IsGenerated) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $parameters = @(GetTemplateParameters);
    $Assert.GreaterOrEqual($parameters, '.', 1);
}

# Synopsis: ARM template variables should be used at least once.
Rule 'Azure.Template.UseVariables' -Type '.json' -If { (IsTemplateFile) } -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $jsonObject = $PSRule.GetContent($TargetObject)[0];
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
        $Assert.Match($jsonContent, '.', "\`"\[[\s\S]*variables\(\s{0,}'$($variableName)'\s{0,}\)[\s\S]*\]\`"").
            Reason($LocalizedData.VariableNotFound, $variableName);
    }
}

# Synopsis: Set the default value for location parameters within ARM template to the default value to `[resourceGroup().location]`.
Rule 'Azure.Template.LocationDefault' -Type '.json' -If { (HasLocationParameter) } -Tag @{ release = 'GA'; ruleSet = '2021_03' } {
    # https://github.com/Azure/arm-ttk/blob/master/arm-ttk/testcases/deploymentTemplate/Location-Should-Not-Be-Hardcoded.test.ps1

    $parameters = @(GetTemplateParameters -Name 'location');
    foreach ($parameter in $parameters) {
        if ($Assert.HasFieldValue($parameter.Value, 'defaultValue', 'global').Result) {
            $Assert.Pass();
        }
        else {
            $defaultValue = [PSRule.Rules.Azure.Runtime.Helper]::CompressExpression($parameter.Value.defaultValue);
            $Assert.HasFieldValue($defaultValue, '.', '[resourceGroup().location]').
                Reason($LocalizedData.ParameterInvalidDefaultValue, $parameter.Name, $parameter.Value.defaultValue);
        }
    }
}

# Synopsis: Location parameters should use a string value.
Rule 'Azure.Template.LocationType' -Type '.json' -If { (HasLocationParameter) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    # https://github.com/Azure/arm-ttk/blob/master/arm-ttk/testcases/deploymentTemplate/Location-Should-Not-Be-Hardcoded.test.ps1

    $parameters = @(GetTemplateParameters -Name 'location');
    foreach ($parameter in $parameters) {
        $Assert.HasFieldValue($parameter.Value, 'type', 'string');
    }
}

# Synopsis: Template resource location should be an expression or `global`.
Rule 'Azure.Template.ResourceLocation' -Type '.json' -If { (HasTemplateResources) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    # https://github.com/Azure/arm-ttk/blob/master/arm-ttk/testcases/deploymentTemplate/Resources-Should-Have-Location.test.ps1

    $resources = @(GetTemplateResources);
    if ($resources.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($resource in $resources) {
        AnyOf {
            $Assert.NotHasField($resource, 'location');
            $Assert.HasFieldValue($resource, 'location', 'global');
            $Assert.Match($resource, 'location', '^\[.*\]$');
        }
    }
}

# Synopsis: Template should reference a location parameter to specify resource location.
Rule 'Azure.Template.UseLocationParameter' -Type '.json' -If { (IsTemplateFile -Suffix '/deploymentTemplate.json') -and !(IsGenerated) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $jsonObject = $PSRule.GetContent($TargetObject)[0];
    if ($Assert.HasField($jsonObject, 'parameters.location').Result) {
        $jsonObject.parameters.PSObject.Properties.Remove('location')
    }
    $content = $jsonObject | ConvertTo-Json -Depth 100;
    $Assert.NotMatch($content, '.', 'resourceGroup\(\s{0,}\)\.location').
        Reason($LocalizedData.ExpressionInTemplate, 'resourceGroup().location');
}

# Synopsis: Template parameters `minValue` and `maxValue` constraints must be valid.
Rule 'Azure.Template.ParameterMinMaxValue' -Type '.json' -If { (HasTemplateParameters) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    # https://github.com/Azure/arm-ttk/blob/master/arm-ttk/testcases/deploymentTemplate/Min-And-Max-Value-Are-Numbers.test.ps1

    # Get parameters with either minValue or maxValue
    $parameters = @(GetTemplateParameters | Where-Object {
        $Assert.HasField($_.Value, @('minValue', 'maxValue')).Result
    });
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.HasFieldValue($parameter.Value, 'type', 'int');
        if ($Assert.HasField($parameter.Value, 'minValue').Result) {
            $Assert.IsInteger($parameter.Value, 'minValue').
                Reason($LocalizedData.ParameterTypeMismatch, 'minValue', $parameter.Name, 'int');
        }
        if ($Assert.HasField($parameter.Value, 'maxValue').Result) {
            $Assert.IsInteger($parameter.Value, 'maxValue').
            Reason($LocalizedData.ParameterTypeMismatch, 'maxValue', $parameter.Name, 'int');
        }
    }
}

# Synopsis: Use default deployment detail level for nested deployments.
Rule 'Azure.Template.DebugDeployment' -Type '.json' -If { (HasTemplateResources) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    # https://github.com/Azure/arm-ttk/blob/master/arm-ttk/testcases/deploymentTemplate/Deployment-Resources-Must-Not-Be-Debug.test.ps1

    # Get deployments
    $resources = @($PSRule.GetContent($TargetObject)[0].resources | Where-Object {
        $Assert.HasFieldValue($_, 'type', 'Microsoft.Resources/deployments').Result
    });
    if ($resources.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($resource in $resources) {
        $Assert.HasDefaultValue($resource, 'properties.debugSetting.detailLevel', 'None');
    }
}

# Synopsis: Set the parameter default value to a value of the same type.
Rule 'Azure.Template.ParameterDataTypes' -Type '.json' -If { (HasTemplateParameters) } -Tag @{ release = 'GA'; ruleSet = '2021_03'; } {
    $jsonObject = $PSRule.GetContent($TargetObject)[0];
    $parameters = @($jsonObject.parameters.PSObject.Properties);
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        if (!$Assert.HasField($parameter.Value, 'defaultValue').Result) {
            # No defaultValue
            $Assert.Pass();
        }
        elseif ($parameter.Value.defaultValue -is [string] -and $parameter.Value.defaultValue.StartsWith('[') -and $parameter.Value.defaultValue.EndsWith(']')) {
            # Is function
            $Assert.Pass();
        }
        elseif ($Null -eq $parameter.Value.defaultValue)
        {
            # defaultValue is null
            $Assert.Pass();
        }
        elseif ($parameter.Value.type -eq 'bool') {
            $Assert.IsBoolean($parameter.Value, 'defaultValue').
                Reason($LocalizedData.ParameterTypeMismatch, 'defaultValue', $parameter.Name, $parameter.Value.type);
        }
        elseif ($parameter.Value.type -eq 'int') {
            $Assert.IsInteger($parameter.Value, 'defaultValue').
                Reason($LocalizedData.ParameterTypeMismatch, 'defaultValue', $parameter.Name, $parameter.Value.type);
        }
        elseif ($parameter.Value.type -eq 'array') {
            $Assert.IsArray($parameter.Value, 'defaultValue').
                Reason($LocalizedData.ParameterTypeMismatch, 'defaultValue', $parameter.Name, $parameter.Value.type);
        }
        elseif ($parameter.Value.type -eq 'string' -or $parameter.Value.type -eq 'secureString') {
            $Assert.IsString($parameter.Value, 'defaultValue').
                Reason($LocalizedData.ParameterTypeMismatch, 'defaultValue', $parameter.Name, $parameter.Value.type);
        }
        elseif ($parameter.Value.type -eq 'object' -or $parameter.Value.type -eq 'secureObject') {
            $Assert.TypeOf($parameter.Value, 'defaultValue', [PSObject]).
                Reason($LocalizedData.ParameterTypeMismatch, 'defaultValue', $parameter.Name, $parameter.Value.type);
        }
    }
}

#endregion Template

#region Parameters

# Synopsis: Use ARM parameter file structure.
Rule 'Azure.Template.ParameterFile' -Type '.json' -If { (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $Assert.HasFields($jsonObject, @('$schema', 'contentVersion', 'parameters'));
    $jsonObject.PSObject.Properties | Within 'Name' '$schema', 'contentVersion', 'metadata', 'parameters';
}

# Synopsis: Use a Azure template parameter schema with the https scheme.
Rule 'Azure.Template.ParameterScheme' -Type '.json' -If { (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $Assert.StartsWith($jsonObject, '$schema', 'https://');
}

# Synopsis: Configure a metadata link for each parameter file.
Rule 'Azure.Template.MetadataLink' -Type '.json' -If { $Configuration.AZURE_PARAMETER_FILE_METADATA_LINK -eq $True -and (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09' } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $field = $Assert.HasFieldValue($jsonObject, 'metadata.template');
    if (!$field.Result) {
        return $field;
    }
    $path = [PSRule.Rules.Azure.Runtime.Helper]::GetMetadataLinkPath($TargetObject.FullName, $jsonObject.metadata.template)
    $Assert.FilePath($path, '.');
    $Assert.WithinPath($path, '.', @($PWD));
}

# Synopsis: Specify a value for each parameter in template parameter files.
Rule 'Azure.Template.ParameterValue' -Type '.json' -If { (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $parameters = @($jsonObject.parameters.PSObject.Properties | Where-Object {
        $_.MemberType -eq 'NoteProperty'
    });
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        if ($Assert.HasField($parameter.Value, 'value').Result -or $Assert.HasFieldValue($parameter.Value, 'reference').Result) {
            $Assert.Pass();
        }
        else {
            $Assert.Fail($LocalizedData.ParameterValueNotSet, $parameter.Name);
        }
    }
}

# Synopsis: Use a valid secret reference within parameter files.
Rule 'Azure.Template.ValidSecretRef' -Type '.json' -If { (IsParameterFile) } -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $jsonObject = $PSRule.GetContentFirstOrDefault($TargetObject);
    $parameters = @($jsonObject.parameters.PSObject.Properties | Where-Object {
        $_.MemberType -eq 'NoteProperty' -and $Assert.HasField($_.Value, 'reference').Result
    });
    if ($parameters.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($parameter in $parameters) {
        $Assert.Match($parameter.Value, 'reference.keyVault.id', '^\/subscriptions\/(.+?)\/resourceGroups\/(.+?)\/providers\/Microsoft\.KeyVault\/vaults\/[A-Za-z](-|[A-Za-z0-9])*[A-Za-z0-9]$');
        $Assert.Match($parameter.Value, 'reference.secretName', '^[A-Za-z0-9-]{1,127}$');
    }
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
        if ($PSRule.TargetType -ne '.json') {
            return $False;
        }
        try {
            $jsonObject = $PSRule.GetContent($TargetObject)[0];
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
            return $targetSchema -in $schemas -and ([String]::IsNullOrEmpty($Suffix) -or $targetSchema.Trim("`#").EndsWith($Suffix));
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
        if ($PSRule.TargetType -ne '.json') {
            return $False;
        }
        try {
            $jsonObject = $PSRule.GetContent($TargetObject)[0];
            $schemas = @(
                # Https
                "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentParameters.json`#"
                "https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentParameters.json`#"

                # Http
                "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
                "http://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
                "http://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentParameters.json`#"
                "http://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentParameters.json`#"
                "http://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentParameters.json`#"
            )
            return $jsonObject.'$schema' -in $schemas;
        }
        catch {
            return $False;
        }
    }
}

function global:HasLocationParameter {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (!(IsTemplateFile -Suffix '/deploymentTemplate.json')) {
            return $False;
        }
        $jsonObject = $PSRule.GetContent($TargetObject)[0];
        return $Assert.HasField($jsonObject, 'parameters.location').Result;
    }
}

function global:HasTemplateParameters {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (!(IsTemplateFile)) {
            return $False;
        }
        $parameters = @($PSRule.GetContent($TargetObject)[0].parameters.PSObject.Properties | Where-Object {
            $_.MemberType -eq 'NoteProperty'
        });
        return $Assert.GreaterOrEqual($parameters, '.', 1).Result;
    }
}

function global:HasTemplateResources {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if (!(IsTemplateFile)) {
            return $False;
        }
        $jsonObject = $PSRule.GetContent($TargetObject)[0].resources;
        return $Assert.GreaterOrEqual($jsonObject, '.', 1).Result;
    }
}

function global:GetTemplateParameters {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$Name
    )
    process {
        $parameters = @($PSRule.GetContent($TargetObject)[0].parameters.PSObject.Properties | Where-Object {
            $_.MemberType -eq 'NoteProperty'
        });
        return $parameters | Where-Object {
            $Null -eq $Name -or $_.Name -in $Name
        };
    }
}

function global:GetTemplateResources {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        $PSRule.GetContent($TargetObject)[0].resources | ForEach-Object {
            # Emit each resource
            $_;

            # Emit resources in nested templates
            if ($Assert.HasFieldValue($_, 'type', 'Microsoft.Resources/deployments').Result -and $Assert.GreaterOrEqual($_, 'properties.template.resources', 1).Result) {
                $_.properties.template.resources;
            }
            # Emit sub-resources
            elseif ($Assert.GreaterOrEqual($_, 'resources', 1).Result) {
                $_.resources;
            }
        }
    }
}

function global:IsGenerated {
    [CmdletBinding()]
    param ()
    process {
        if ($PSRule.TargetType -ne '.json') {
            return $False;
        }
        try {
            $jsonObject = $PSRule.GetContent($TargetObject)[0];
            return $Assert.HasFieldValue($jsonObject, 'metadata._generator.name', 'bicep').Result -or
                $Assert.HasFieldValue($jsonObject, 'metadata._generator.name', 'psarm').Result;
        }
        catch {
            return $False;
        }
    }
}

#endregion Helper functions
