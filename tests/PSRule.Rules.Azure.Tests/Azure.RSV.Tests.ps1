# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Recovery Services Vault (RSV) rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.RSV' -Tag 'RSV' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.RSV.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.RSV.StorageType' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RSV.StorageType' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vaultconfig-a', 'vault-f';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vaultconfig-b', 'vaultconfig-c', 'vaultconfig-d', 'vault-e', 'vault-g';
        }

        It 'Azure.RSV.ReplicationAlert' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RSV.ReplicationAlert' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });           
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'replication-alert-a', 'vault-f', 'vault-e';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'replication-alert-b', 'vault-g', 'replication-alert-c';
        }

        It 'Azure.RSV.Immutable' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RSV.Immutable' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vault-e', 'vault-f';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.securitySettings.immutabilitySettings.state';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vault-g';
        }
    }

    Context 'Resource name - Azure.RSV.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.RecoveryServices/vaults'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'a1'
                'A1'
                'a-'
                'A-'
                'contoso-001-rsv'
                'contoso001rsv'
                'CONTOSO-001-AGW'
                'CONTOSO-001-AGW-'
            )

            $invalidNames = @(
                '-a'
                '-A'
                '_a'
                '_A'
                '1'
                '11'
                '_1'
                '-1'
                '-'
                '_'
                '-contoso-001-rsv'
                '-contoso-001-rsv-'
                '-_contoso-001-rsv'
                'CONTOSO-001-RSV.'
                '-CONTOSO-001-RSV'
                'CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-001-RSV'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.RSV.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.RSV.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}
