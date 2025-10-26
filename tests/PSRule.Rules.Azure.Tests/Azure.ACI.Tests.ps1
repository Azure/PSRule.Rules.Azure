# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Container Instances
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

Describe 'Azure.ACI' -Tag 'ACI' {
    Context 'Resource naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_CONTAINER_INSTANCE_NAME_FORMAT' = '^ci-'
            };

            $names = @('instance-001', 'ci-001', 'CI-001')
            $items = @($names | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.ContainerInstance/containerGroups'
                    }
                });

            $result = $items | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.ACI.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACI.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'instance-001', 'CI-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ci-001';
        }
    }
}
