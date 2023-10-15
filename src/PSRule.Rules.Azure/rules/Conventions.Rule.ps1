# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Conventions definitions
#

# Synopsis: Flags warnings for deprecated options.
Export-PSRuleConvention 'Azure.DeprecatedOptions' -Initialize {
    $aksMinimumVersion = $Configuration.GetValueOrDefault('Azure_AKSMinimumVersion', $Null);
    if ($Null -ne $aksMinimumVersion) {
        Write-Warning -Message $LocalizedData.AKSMinimumVersionReplace;
    }

    $allowedRegions = $Configuration.GetValueOrDefault('Azure_AllowedRegions', $Null);
    if ($Null -ne $allowedRegions) {
        Write-Warning -Message $LocalizedData.AzureAllowedRegionsReplace;
    }
}

# Synopsis: Create a context singleton.
Export-PSRuleConvention 'Azure.Context' -Initialize {
    Write-Verbose "[Azure.Context] -- Initializing Azure context.";
    $minimum = $Configuration.GetValueOrDefault('AZURE_BICEP_MINIMUM_VERSION', '0.4.451');
    $timeout = $Configuration.GetIntegerOrDefault('AZURE_BICEP_FILE_EXPANSION_TIMEOUT', 5);
    $check = $Configuration.GetBoolOrDefault('AZURE_BICEP_CHECK_TOOL', $False);
    $allowedRegions = @($Configuration.GetValueOrDefault('Azure_AllowedRegions', $Configuration.GetStringValues('AZURE_RESOURCE_ALLOWED_LOCATIONS')));
    $service = [PSRule.Rules.Azure.Runtime.Helper]::CreateService($minimum, $timeout);

    if ($allowedRegions.Length -gt 0) {
        $service.WithAllowedLocations($allowedRegions);
    }

    if ($check) {
        Write-Verbose "[Azure.Context] -- Checking Bicep CLI.";
        $version = [PSRule.Rules.Azure.Runtime.Helper]::GetBicepVersion($service);
        if ([System.Version]::Parse($version) -lt [System.Version]::Parse($minimum)) {
            Write-Error -Message ($LocalizedData.BicepCLIVersion -f $version, $minimum);
        }
        else {
            Write-Verbose "[Azure.Context] -- Using Bicep CLI: $version";
        }
    }
    $PSRule.AddService('Azure.Context', $service);
}

# Synopsis: Expand Azure resources from parameter files.
Export-PSRuleConvention 'Azure.ExpandTemplate' -If { $Configuration.AZURE_PARAMETER_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.json' -and $Assert.HasJsonSchema($PSRule.GetContentFirstOrDefault($TargetObject), @(
    "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
    "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
), $True) } -Begin {
    Write-Verbose "[Azure.ExpandTemplate] -- Expanding parameter file: $($TargetObject.FullName)";
    $context = $PSRule.GetService('Azure.Context');
    try {
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetResources($context, $TargetObject.FullName);
        if ($Null -ne $data) {
            $PSRule.Import($data);
        }
    }
    catch [PSRule.Rules.Azure.Data.Template.TemplateException] {
        Write-Error -Exception $_.Exception;
    }
    catch [PSRule.Rules.Azure.Pipeline.TemplateReadException] {
        Write-Error -Exception $_.Exception;
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Exception $_.Exception;
    }
    catch {
        Write-Error -Message "Failed to expand parameter file '$($TargetObject.FullName)'. $($_.Exception.Message)" -ErrorId 'Azure.ExpandTemplate.ConventionException';
    }
}

#region Bicep

# Synopsis: Install Bicep for expansion of .bicep files within GitHub Actions.
Export-PSRuleConvention 'Azure.BicepInstall' -If { $Configuration.AZURE_BICEP_FILE_EXPANSION -eq $True -and $Env:GITHUB_ACTION -eq '__Microsoft_ps-rule' } -Initialize {

    # Skip if already installed
    if (Test-Path -Path '/usr/local/bin/bicep') {
        return
    }

    # Install the latest Bicep CLI binary for alpine
    Invoke-WebRequest -Uri 'https://github.com/Azure/bicep/releases/latest/download/bicep-linux-musl-x64' -OutFile $Env:GITHUB_WORKSPACE/bicep.bin

    # Set executable
    chmod +x $Env:GITHUB_WORKSPACE/bicep.bin

    # Copy to PATH environment
    Move-Item $Env:GITHUB_WORKSPACE/bicep.bin /usr/local/bin/bicep
}

Export-PSRuleConvention 'Azure.ExpandBicep' -If { $Configuration.AZURE_BICEP_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.bicep' } -Begin {
    Write-Verbose "[Azure.ExpandBicep] -- Start expanding bicep source: $($TargetObject.FullName)";
    $context = $PSRule.GetService('Azure.Context');
    try {
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetBicepResources($context, $TargetObject.FullName);
        if ($Null -ne $data) {
            Write-Verbose "[Azure.ExpandBicep] -- Importing $($data.Length) Bicep resources.";
            $PSRule.Import($data);
        }
    }
    catch [PSRule.Rules.Azure.Pipeline.BicepCompileException] {
        Write-Error -Exception $_.Exception -ErrorId 'Azure.ExpandBicep.BicepCompileException';
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Exception $_.Exception;
    }
    catch {
        Write-Error -Message "Failed to expand bicep source '$($TargetObject.FullName)'. $($_.Exception.Message)" -ErrorId 'Azure.ExpandBicep.ConventionException';
    }
    Write-Verbose "[Azure.ExpandBicep] -- Complete expanding bicep source: $($TargetObject.FullName)";
}

# Synopsis: Expand .bicepparam files for analysis.
Export-PSRuleConvention 'Azure.ExpandBicepParam' -If { $Configuration.AZURE_BICEP_PARAMS_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.bicepparam' } -Begin {
    Write-Verbose "[Azure.ExpandBicepParam] -- Start expanding bicep from parameter file: $($TargetObject.FullName)";
    $context = $PSRule.GetService('Azure.Context');
    try {
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetBicepParamResources($context, $TargetObject.FullName);
        if ($Null -ne $data) {
            Write-Verbose "[Azure.ExpandBicepParam] -- Importing $($data.Length) Bicep resources.";
            $PSRule.Import($data);
        }
    }
    catch [PSRule.Rules.Azure.Pipeline.BicepCompileException] {
        Write-Error -Exception $_.Exception -ErrorId 'Azure.ExpandBicepParam.BicepCompileException';
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Exception $_.Exception;
    }
    catch {
        Write-Error -Message "Failed to expand bicep source '$($TargetObject.FullName)'. $($_.Exception.Message)" -ErrorId 'Azure.ExpandBicepParam.ConventionException';
    }
    Write-Verbose "[Azure.ExpandBicepParam] -- Complete expanding bicep source: $($TargetObject.FullName)";
}

#endregion Bicep
