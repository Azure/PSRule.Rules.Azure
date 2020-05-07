# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Storage Account rules
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

Describe 'Azure.Storage' -Tag Storage {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Storage.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.Storage.UseReplication' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.UseReplication' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'storage-B', 'storage-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-A';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-D';
        }

        It 'Azure.Storage.SecureTransfer' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.SecureTransfer' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'storage-B', 'storage-C', 'storage-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-A';
        }

        It 'Azure.Storage.UseEncryption' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.UseEncryption' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'storage-B', 'storage-C', 'storage-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-A';
        }

        It 'Azure.Storage.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.SoftDelete' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'storage-B', 'storage-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-A';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage-D';
        }

        It 'Azure.Storage.BlobAccessType' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.BlobAccessType' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'storage-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'storage-A', 'storage-C', 'storage-D';
        }
    }

    Context 'With Template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Storage.Template.json';
        $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Storage.Parameters.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Storage.json;
        Export-AzTemplateRuleData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop -Culture 'en-US';

        It 'Azure.Storage.UseReplication' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.UseReplication' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage1';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.Storage.SecureTransfer' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.SecureTransfer' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage1';
        }

        It 'Azure.Storage.UseEncryption' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.UseEncryption' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'storage1';
        }

        It 'Azure.Storage.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.SoftDelete' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'storage1';
        }

        It 'Azure.Storage.BlobAccessType' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Storage.BlobAccessType' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'storage1', 'storage1/default/arm';
        }
    }
}
