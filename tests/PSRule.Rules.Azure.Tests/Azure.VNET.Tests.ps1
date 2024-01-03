# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Virtual Network rules
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

Describe 'Azure.VNET' -Tag 'Network', 'VNET' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option        = @{
                    'Configuration.AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG' = @('subnet-ZZ')
                }
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-C', 'vnet-D';
            
            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 4;
            $ruleResult[0].Reason | Should -Be @(
                "The subnet (AzureBastionSubnet) has no NSG associated.",
                "The subnet (subnet-B) has no NSG associated.", 
                "The subnet (subnet-C) has no NSG associated.", 
                "The subnet (subnet-D) has no NSG associated."
            );
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -HaveCount 3;
            $ruleResult[1].Reason | Should -Be @(
                "The subnet (subnet-B) has no NSG associated.", 
                "The subnet (subnet-C) has no NSG associated.", 
                "The subnet (subnet-D) has no NSG associated."
            );
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -HaveCount 3;
            $ruleResult[2].Reason | Should -Be @(
                "The subnet (subnet-B) has no NSG associated.", 
                "The subnet (subnet-C) has no NSG associated.", 
                "The subnet (subnet-D) has no NSG associated."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-E', 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.SingleDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SingleDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'vnet-B', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-C';
        }

        It 'Azure.VNET.PeerState' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.PeerState' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-B';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetObject.ResourceType -eq 'Microsoft.Network/virtualNetworks' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.SubnetName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SubnetName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.BastionSubnet' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.BastionSubnet' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-C';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.subnets: The subnet 'AzureBastionSubnet' was expected but has not been defined.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.subnets: The subnet 'AzureBastionSubnet' was expected but has not been defined.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-D', 'vnet-E';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetObject.ResourceType -eq 'Microsoft.Network/virtualNetworks' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vnet-F', 'vnet-G';
        }

        It 'Azure.VNET.FirewallSubnet' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.FirewallSubnet' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-C', 'vnet-D';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.subnets: The subnet 'AzureFirewallSubnet' was expected but has not been defined.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.subnets: The subnet 'AzureFirewallSubnet' was expected but has not been defined.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-E';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetObject.ResourceType -eq 'Microsoft.Network/virtualNetworks' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vnet-F', 'vnet-G';
        }
    }

    Context 'Resource name - Azure.VNET.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.Network/virtualNetworks'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'vnet-001'
                'vnet-001_'
                'VNET.001'
            )

            $invalidNames = @(
                '_vnet-001'
                '-vnet-001'
                'vnet-001-'
                'v'
                'vnet-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNET.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNET.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.VNET.SubnetName' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.Network/virtualNetworks/subnets'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'snet-001'
                'snet-001_'
                'SNET.001'
                's'
                'vnet-001/GatewaySubnet'
            )

            $invalidNames = @(
                '_snet-001'
                '-snet-001'
                'snet-001-'
                'snet-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNET.SubnetName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNET.SubnetName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'vnet.tests.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualNetwork.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop -Culture 'en-US';
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vnet-002/subnet-extra';
            $ruleResult.Reason | Should -BeLike 'The subnet (*) has no NSG associated.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vnet-001';
        }

        It 'Azure.VNET.SingleDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SingleDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
        }

        It 'Azure.VNET.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VNET.PeerState' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.PeerState' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.Network/virtualNetworks' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
        }
    }

    Context 'With configuration' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option = @{
                    'Configuration.AZURE_VNET_DNS_WITH_IDENTITY' = $true
                }
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Name 'Azure.VNET.LocalDNS';
        }

        It 'Azure.VNET.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }
    }
}
