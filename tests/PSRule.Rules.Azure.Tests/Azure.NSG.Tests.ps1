# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Network Security Group (NSG) rules
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


Describe 'Azure.NSG' -Tag 'Network', 'NSG' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.NSG.AnyInboundSource' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.AnyInboundSource' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-C', 'nsg-D', 'nsg-E', 'aks-agentpool-00000000-nsg', 'aks-agentpool-00000001-nsg';
        }

        It 'Azure.NSG.DenyAllInbound' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.DenyAllInbound' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The first inbound rule denies traffic from all sources.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-B', 'nsg-D', 'nsg-E', 'aks-agentpool-00000000-nsg', 'aks-agentpool-00000001-nsg';
        }

        It 'Azure.NSG.LateralTraversal' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.LateralTraversal' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nsg-C', 'aks-agentpool-00000000-nsg', 'aks-agentpool-00000001-nsg';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "A rule to limit lateral traversal was not found.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-B', 'nsg-D', 'nsg-E';
        }

        It 'Azure.NSG.Associated' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.Associated' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nsg-B', 'nsg-C', 'nsg-D', 'nsg-E';
            
            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The resource is not associated.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The resource is not associated.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The resource is not associated.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The resource is not associated.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-A';
        }

        It 'Azure.NSG.AKSRules' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.AKSRules' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            
            $ruleResult.TargetName | Should -Be 'aks-agentpool-00000001-nsg';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'aks-agentpool-00000000-nsg';
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_NETWORK_SECURITY_GROUP_NAME_FORMAT' = '^nsg-' };

            $names = @(
                'nsg-001'
                'nsg-001_'
                'NSG.001'
                'n'
                '_nsg-001'
                '-nsg-001'
                'nsg-001-'
                'nsg-001.'
                'NSG-001'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Network/networkSecurityGroups'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.NSG.Name','Azure.NSG.Naming'
        }

        It 'Azure.NSG.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.Name' };
            $validNames = @(
                'nsg-001'
                'nsg-001_'
                'NSG.001'
                'n'
                'NSG-001'
            )

            $invalidNames = @(
                '_nsg-001'
                '-nsg-001'
                'nsg-001-'
                'nsg-001.'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }

        It 'Azure.NSG.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.Naming' };
            $validNames = @(
                'nsg-001'
                'nsg-001_'
                'nsg-001-'
                'nsg-001.'
            )

            $invalidNames = @(
                'NSG.001'
                '_nsg-001'
                '-nsg-001'
                'n'
                'NSG-001'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualNetwork.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.NSG.AnyInboundSource' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.AnyInboundSource' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';
        }

        It 'Azure.NSG.DenyAllInbound' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.DenyAllInbound' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nsg-subnet1', 'nsg-extra';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nsg-subnet2';
        }

        It 'Azure.NSG.LateralTraversal' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.LateralTraversal' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nsg-subnet2', 'nsg-extra';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-subnet1';
        }

        It 'Azure.NSG.Associated' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.Associated' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.Network/networkSecurityGroups' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';
        }
    }
}
