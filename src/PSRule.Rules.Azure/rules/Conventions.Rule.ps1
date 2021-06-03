# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Conventions definitions
#

# Synopsis: Expand Azure resources from parameter files.
Export-PSRuleConvention 'Azure.ExpandTemplate' -If { $Configuration.AZURE_PARAMETER_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.json' -and $Assert.HasJsonSchema($PSRule.GetContentFirstOrDefault($TargetObject), @(
    "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
    "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
), $True) } -Begin {
    Write-Verbose "[Azure.ExpandTemplate] -- Expanding parameter file: $($TargetObject.FullName)";
    try {
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetResources($TargetObject.FullName);
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
