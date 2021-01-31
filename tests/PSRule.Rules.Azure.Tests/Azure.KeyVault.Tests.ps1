# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Key Vault rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.KeyVault' -Tag 'KeyVault' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.KeyVault.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.KeyVault.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.SoftDelete' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-C';
        }

        It 'Azure.KeyVault.PurgeProtect' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.PurgeProtect' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-B', 'keyvault-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A';
        }

        It 'Azure.KeyVault.AccessPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AccessPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-C';
        }

        It 'Azure.KeyVault.Logs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Logs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-B', 'keyvault-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A';
        }
    }

    Context 'With Template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template2.json';
        $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters2.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.KeyVault.json;
        Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.KeyVault.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.SoftDelete' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.PurgeProtect' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.PurgeProtect' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.AccessPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AccessPolicy' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.Logs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Logs' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }
    }
}
