# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Service Bus rules
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

Describe 'Azure.ServiceBus' -Tag 'ServiceBus' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ServiceBus.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.ServiceBus.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceBus.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'servicens-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'servicens-B';
        }

        It 'Azure.ServiceBus.Usage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceBus.Usage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'servicens-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'servicens-B';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.ServiceBus.json;
            Export-AzRuleTemplateData -TemplateFile (Join-Path -Path $here -ChildPath 'Resources.ServiceBus.Template.json') -OutputPath $outputFile;
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.ServiceBus.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceBus.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'servicens-001';
        }
    }
}
