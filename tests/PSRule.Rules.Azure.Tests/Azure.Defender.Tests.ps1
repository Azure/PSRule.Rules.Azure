# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Microsoft Defender for Cloud
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

Describe 'Azure.Defender' -Tag 'MDC', 'Defender' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Defender.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Defender.Containers' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Containers' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderB';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderA';
        }
        
        It 'Azure.Defender.Servers' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Servers' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderD', 'defenderE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderC';
        }

        It 'Azure.Defender.SQL' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.SQL' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderG';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderF';
        }

        It 'Azure.Defender.AppServices' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.AppServices' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderI';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderH';
        }

        It 'Azure.Defender.Storage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Storage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderK';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderJ';
        }

        It 'Azure.Defender.SQLOnVM' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.SQLOnVM' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderM';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderL';
        }

        It 'Azure.Defender.KeyVault' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.KeyVault' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderO';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderN';
        }

        It 'Azure.Defender.Dns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Dns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderQ';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderP';
        }

        It 'Azure.Defender.Arm' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Arm' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderS';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderR';
        }

        It 'Azure.Defender.Cspm' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Cspm' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderU';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderT';
        }

        It 'Azure.Defender.Api' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.Api' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderW';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderV';
        }

        It 'Azure.Defender.CosmosDb' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.CosmosDb' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderY';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderX';
        }

        It 'Azure.Defender.OssRdb' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.OssRdb' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderA2';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetObject.Name | Should -BeIn 'defenderZ';
        }
    }
}
