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

Describe 'Bicep' -Tag 'Bicep' {
    Context 'Azure.ExpandBicep convention' {
        It 'Expands Bicep source files' {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            # Default
            $sourceFile = Join-Path -Path $rootPath -ChildPath 'docs/examples.bicep';
            $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File);
            $result | Should -BeNullOrEmpty;

            # Expand source files
            $option = @{
                'Configuration.AZURE_BICEP_FILE_EXPANSION' = $True
                'Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT' = 60
            }
            $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option);
            $result.Length | Should -BeGreaterThan 1;
            $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Network/networkSecurityGroups' };
            $resource | Should -Not -BeNullOrEmpty;
            $resource.TargetName | Should -BeIn 'nsg-001'
        }

        It 'Expands Bicep source files with Azure CLI' {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            # Default
            $sourceFile = Join-Path -Path $rootPath -ChildPath 'docs/examples.bicep';
            $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File);
            $result | Should -BeNullOrEmpty;

            try {
                # Install CLI
                az bicep install
                az bicep upgrade

                # Expand source files
                $option = @{
                    'Configuration.AZURE_BICEP_FILE_EXPANSION' = $True
                    'Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT' = 60
                }
                $Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true';
                $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option);
                $result.Length | Should -BeGreaterThan 1;
                $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Network/networkSecurityGroups' };
                $resource | Should -Not -BeNullOrEmpty;
                $resource.TargetName | Should -BeIn 'nsg-001';
            }
            finally {
                Remove-Item 'Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI' -Force;
            }
        }

        It 'Expands Bicep with JSON parameters file' {
            $invokeParams = @{
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Name = 'Azure.Storage.Name'
            }

            # Default
            $sourceFile = Join-Path -Path $here -ChildPath 'template.parameters.json';

            try {
                # Install CLI
                az bicep install

                # Expand source files
                $option = @{
                    'Configuration.AZURE_PARAMETER_FILE_EXPANSION' = $True
                    'Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT' = 60
                }
                $Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true';
                $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option);
                $result.Length | Should -Be 1;
                $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Storage/storageAccounts' };
                $resource | Should -Not -BeNullOrEmpty;
                $resource.TargetName | Should -Be 'bicepstorage001';
                $resource.TargetObject.tags.env | Should -Be 'test';
            }
            finally {
                Remove-Item 'Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI' -Force;
            }
        }

        It 'Expands Bicep with .bicepparams file' {
            $invokeParams = @{
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Name = 'Azure.Storage.Name'
            }

            # Default
            $sourceFile = Join-Path -Path $here -ChildPath 'template.bicepparam';

            # Expand source files
            $option = @{
                'Configuration.AZURE_BICEP_PARAMS_FILE_EXPANSION' = $True
            }
            $result = @(Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option);
            $result.Length | Should -Be 1;
            $resource = $result | Where-Object { $_.TargetType -eq 'Microsoft.Storage/storageAccounts' };
            $resource | Should -Not -BeNullOrEmpty;
            $resource.TargetName | Should -Be 'bicepstorage001';
            $resource.TargetObject.tags.env | Should -Be 'test';
        }

        It 'Bicep expand completes with errors' {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            # Default
            $sourceFile = Join-Path -Path $here -ChildPath 'template.bicep';
            try {
                # Install CLI
                az bicep install

                # Expand source files
                $option = @{
                    'Configuration.AZURE_BICEP_FILE_EXPANSION' = $True
                    'Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT' = 60
                }
                $Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true';
                $sourceFile = Join-Path -Path $here -ChildPath 'template.bicep';
                { $Null = Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option; } | Should -Throw;
            }
            finally {
                Remove-Item 'Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI' -Force;
            }
        }

        It 'Bicep error message filtered' {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            try {
                # Install CLI
                az bicep install

                # Expand source files
                $option = @{
                    'Configuration.AZURE_BICEP_FILE_EXPANSION' = $True
                    'Configuration.AZURE_BICEP_FILE_EXPANSION_TIMEOUT' = 60
                }
                $Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI = 'true';

                # Process file with errors
                $sourceFile = Join-Path -Path $here -ChildPath 'error.bicep';
                $Null = Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option -ErrorVariable errors -ErrorAction SilentlyContinue;
                $bicepError = @($errors | Where-Object {
                    $_.Exception -is [PSRule.Rules.Azure.Pipeline.BicepCompileException]
                })
                $bicepError.Exception.Message | Should -BeLike "*: Error BCP019:*";

                # Process file without errors
                $sourceFile = Join-Path -Path $here -ChildPath 'noterror.bicep';
                $Null = Invoke-PSRule @invokeParams -InputPath $sourceFile -Format File -Option $option -ErrorVariable errors -ErrorAction SilentlyContinue;
                $bicepError = @($errors | Where-Object {
                    $_.Exception -is [PSRule.Rules.Azure.Pipeline.BicepCompileException]
                })
                $bicepError.Length | Should -Be 0;
            }
            finally {
                Remove-Item 'Env:PSRULE_AZURE_BICEP_USE_AZURE_CLI' -Force;
            }
        }
    }
}
