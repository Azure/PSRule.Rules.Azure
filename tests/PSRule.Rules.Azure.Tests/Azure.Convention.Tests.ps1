# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure conventions
#

[CmdletBinding()]
param ()

BeforeAll {
    # Setup error handling
    $ErrorActionPreference = 'Stop';
    Set-StrictMode -Version latest;

    if ($Env:SYSTEM_DEBUG -eq 'true') {
        $VerbosePreference = 'Continue';
    }

    # Setup tests paths
    $rootPath = $PWD;
    Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    $here = (Resolve-Path $PSScriptRoot).Path;
}

Describe 'Azure.ExpandTemplate' -Tag 'Convention' {
    Context 'Convention' {
        It 'Expands template parameter files' {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            # Default
            $parameterFile = Join-Path -Path $here -ChildPath 'Resources.Storage.Parameters.json';
            $result = @(Invoke-PSRule @invokeParams -InputPath $parameterFile -Format File);
            $result.RuleName | Should -BeIn @(
                'Azure.Template.ParameterFile'
                'Azure.Template.ParameterScheme'
            );
            $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Storage/storageAccounts' };
            $resource | Should -BeNullOrEmpty;

            # Expand templates
            $option = @{
                'Configuration.AZURE_PARAMETER_FILE_EXPANSION' = $True
            }
            $result = @(Invoke-PSRule @invokeParams -InputPath $parameterFile -Format File -Option $option);
            $result.Length | Should -BeGreaterThan 1;
            $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Storage/storageAccounts' };
            $resource | Should -Not -BeNullOrEmpty;
            $resource.TargetName | Should -BeIn 'storage1'
        }
    }
}
