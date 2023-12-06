# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Network interface rules.
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

Describe 'Azure.VM' -Tag 'NIC' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Option = (Join-Path -Path $here -ChildPath 'ps-rule-options.yaml')
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.json'
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.NIC.Attached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NIC.Attached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nic-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'nic-A', 'nic-B', 'aks-agentpool-00000000-nic-1', 'aks-agentpool-00000000-nic-2', 'aks-agentpool-00000000-nic-3', 'pe-001', 'private-link.nic.00000000-0000-0000-0000-000000000000';
        }

        It 'Azure.NIC.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NIC.UniqueDns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nic-A', 'nic-B', 'nic-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-nic-1', 'aks-agentpool-00000000-nic-2', 'aks-agentpool-00000000-nic-3', 'pe-001', 'private-link.nic.00000000-0000-0000-0000-000000000000';
        }
    }

    Context 'Resource name - Azure.NIC.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/networkInterfaces'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'nic-001'
                'nic-001_'
                'NIC.001'
                'n'
            )

            $invalidNames = @(
                '_nic-001'
                '-nic-001'
                '.nic-001'
                'nic-001-'
                'nic-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.NIC.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.NIC.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualMachineTemplate.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.NIC.Attached' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.NIC.Attached' -and
                $_.TargetType -eq 'Microsoft.Network/networkInterfaces'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A-nic1';
        }

        It 'Azure.NIC.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NIC.UniqueDns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A-nic1';
        }
    }
}
