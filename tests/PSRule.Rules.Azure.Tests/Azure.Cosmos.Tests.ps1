# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Cosmos DB rules
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

Describe 'Azure.Cosmos' -Tag 'Cosmos', 'CosmosDB' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Cosmos.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Cosmos.DisableMetadataWrite' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableMetadataWrite' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'graph-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'graph-B';
        }
    }

    Context 'Resource name - Azure.Cosmos.AccountName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'db1'
                'db-1'
            )

            $invalidNames = @(
                '_db1'
                '-db1'
                'db.1'
                'db-'
                'db'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Cosmos.AccountName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Cosmos.AccountName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Cosmos.Parameters.*.json';
            $invokeParams = @{
                Baseline = 'Azure.All'
                Option = (Join-Path -Path $here -ChildPath 'test-template-options.yaml')
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $templatePath;
        }

        It 'Azure.Cosmos.DisableMetadataWrite' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableMetadataWrite' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gremlin-002';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gremlin-001';
        }

        It 'Azure.Cosmos.DefenderCloud' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DefenderCloud' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'graph-B','nosql-A', 'nosql-B';

            $ruleResult[0].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Security/advancedThreatProtectionSettings' has not been specified.";
            $ruleResult[1].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Security/advancedThreatProtectionSettings' has not been specified.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }
    }
}
