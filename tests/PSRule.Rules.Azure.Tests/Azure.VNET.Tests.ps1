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
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-G', 'vnet-H/excludedSubnet';
            $ruleResult.Length | Should -Be 6;
            
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
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -HaveCount 1;
            $ruleResult[3].Reason | Should -Be "The subnet (subnet-B) has no NSG associated.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -HaveCount 1;
            $ruleResult[4].Reason | Should -Be "The subnet (subnet-ZZ) has no NSG associated.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -HaveCount 1;
            $ruleResult[5].Reason | Should -Be "The subnet (vnet-H/excludedSubnet) has no NSG associated.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-F', 'vnet-H/AzureFirewallSubnet', 'vnet-I/AzureFirewallSubnet', 'vnet-J/AzureFirewallSubnet', 'vnet-H/subnet-A', 'vnet-H/subnet-B', 'vnet-H/subnet-C';
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
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G', 'vnet-H/AzureFirewallSubnet', 'vnet-I/AzureFirewallSubnet', 'vnet-H/excludedSubnet', 'vnet-J/AzureFirewallSubnet', 'vnet-H/subnet-A', 'vnet-H/subnet-B', 'vnet-H/subnet-C';
            $ruleResult.Length | Should -Be 14;
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

        It 'Azure.VNET.FirewallSubnetNAT' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.FirewallSubnetNAT' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VNET.PrivateSubnet' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.PrivateSubnet' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-G', 'vnet-H/excludedSubnet', 'vnet-H/subnet-A', 'vnet-H/subnet-B';

            $ruleResult[0].Reason | Should -BeExactly @(
                "The subnet (subnet-A) should disable default outbound access."
                "The subnet (subnet-B) should disable default outbound access."
                "The subnet (subnet-C) should disable default outbound access."
                "The subnet (subnet-D) should disable default outbound access."
            );
            $ruleResult[1].Reason | Should -BeExactly @(
                "The subnet (subnet-A) should disable default outbound access."
                "The subnet (subnet-B) should disable default outbound access."
                "The subnet (subnet-C) should disable default outbound access."
                "The subnet (subnet-D) should disable default outbound access."
            );
            $ruleResult[2].Reason | Should -BeExactly @(
                "The subnet (subnet-A) should disable default outbound access."
                "The subnet (subnet-B) should disable default outbound access."
                "The subnet (subnet-C) should disable default outbound access."
                "The subnet (subnet-D) should disable default outbound access."
            );
            $ruleResult[3].Reason | Should -BeExactly "The subnet (subnet-ZZ) should disable default outbound access.";
            $ruleResult[4].Reason | Should -BeExactly "The subnet (vnet-H/excludedSubnet) should disable default outbound access.";
            $ruleResult[5].Reason | Should -BeExactly "The subnet (vnet-H/subnet-A) should disable default outbound access.";
            $ruleResult[6].Reason | Should -BeExactly "The subnet (vnet-H/subnet-B) should disable default outbound access.";
  
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-H/AzureFirewallSubnet', 'vnet-I/AzureFirewallSubnet', 'vnet-J/AzureFirewallSubnet', 'vnet-H/subnet-C';
        }
    }

    Context 'Resource name - VNET' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_VNET_NAME_FORMAT' = '^vnet-' };

            $names = @(
                'vnet-001'
                'vnet-001_'
                'VNET.001'
                '_vnet-001'
                '-vnet-001'
                'vnet-001-'
                'v'
                'vnet-001.'
                'VNET-001'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Network/virtualNetworks'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.VNET.Name','Azure.VNET.Naming'
        }

        It 'Azure.VNET.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.Name' };
            $validNames = @(
                'vnet-001'
                'vnet-001_'
                'VNET.001'
                'VNET-001'
            )

            $invalidNames = @(
                '_vnet-001'
                '-vnet-001'
                'vnet-001-'
                'v'
                'vnet-001.'
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

        It 'Azure.VNET.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.Naming' };
            $validNames = @(
                'vnet-001'
                'vnet-001_'
                'vnet-001-'
                'vnet-001.'
            )

            $invalidNames = @(
                'VNET.001'
                '_vnet-001'
                '-vnet-001'
                'v'
                'VNET-001'
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

    Context 'Resource name - Subnet' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_VNET_SUBNET_NAME_FORMAT' = '^snet-' };

            $names = @(
                'snet-001'
                'snet-001_'
                'SNET.001'
                's'
                'vnet-001/GatewaySubnet'
                '_snet-001'
                '-snet-001'
                'snet-001-'
                'snet-001.'
                'SNET-001'
                'vnet-001/snet-001'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Network/virtualNetworks/subnets'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.VNET.SubnetName','Azure.VNET.SubnetNaming'
        }

        It 'Azure.VNET.SubnetName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SubnetName' };
            $validNames = @(
                'snet-001'
                'snet-001_'
                'SNET.001'
                's'
                'vnet-001/GatewaySubnet'
                'SNET-001'
                'vnet-001/snet-001'
            )

            $invalidNames = @(
                '_snet-001'
                '-snet-001'
                'snet-001-'
                'snet-001.'
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

        It 'Azure.VNET.SubnetNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SubnetNaming' };
            $validNames = @(
                'snet-001'
                'snet-001_'
                'snet-001-'
                'snet-001.'
                'vnet-001/GatewaySubnet'
                'vnet-001/snet-001'
            )

            $invalidNames = @(
                '_snet-001'
                '-snet-001'
                's'
                'SNET-001'
                'SNET.001'
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
            $templatePath = Join-Path -Path $here -ChildPath 'vnet.tests.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualNetwork.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $option = New-PSRuleOption -Configuration @{ 'AZURE_VNET_SUBNET_NAME_FORMAT' = '^snet-' };
            $invokeParams = @{
                Module = 'PSRule.Rules.Azure'
                InputPath = $outputFile
                Outcome = 'All'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Culture = 'en-US'
                Option = $option
                Name = @('Azure.VNET.UseNSGs', 'Azure.VNET.SingleDNS', 'Azure.VNET.LocalDNS', 'Azure.VNET.PeerState', 'Azure.VNET.SubnetNaming')
            }
            $result = Invoke-PSRule @invokeParams;
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'vnet-002/subnet-extra', 'vnet-embedded-subnet', 'vnet-separate-subnet';
            $ruleResult.Length | Should -Be 3;
            $ruleResult.Reason | Should -BeLike 'The subnet (*) has no NSG associated.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'vnet-001', 'vnet-empty';
            $ruleResult.Length | Should -Be 2;
        }

        It 'Azure.VNET.SingleDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SingleDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'vnet-001', 'vnet-empty', 'vnet-separate-subnet', 'vnet-embedded-subnet';
            $ruleResult.Length | Should -Be 4;
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
            $ruleResult.TargetName | Should -BeIn 'vnet-001', 'vnet-empty', 'vnet-separate-subnet', 'vnet-embedded-subnet';
            $ruleResult.Length | Should -Be 4;
        }

        It 'Azure.VNET.SubnetNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SubnetNaming' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.TargetName | Should -BeIn 'vnet-002/subnet-extra', 'vnet-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.TargetName | Should -BeIn 'vnet-empty', 'vnet-separate-subnet', 'vnet-embedded-subnet';

            # # None
            # $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.Network/virtualNetworks' });
            # $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 1;
            # $ruleResult.TargetName | Should -Be 'vnet-001';
        }
    }

    Context 'With configuration' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option        = @{
                    'Configuration.AZURE_VNET_DNS_WITH_IDENTITY'        = $True
                    'Configuration.AZURE_FIREWALL_IS_ZONAL'             = $True
                    'Configuration.AZURE_VNET_SUBNET_EXCLUDED_FROM_NSG' = @('subnet-ZZ', 'excludedSubnet') 
                }
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Name 'Azure.VNET.LocalDNS', 'Azure.VNET.UseNSGs', 'Azure.VNET.FirewallSubnetNAT';
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
        
        It 'Azure.VNET.FirewallSubnetNAT' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.FirewallSubnetNAT' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-H/AzureFirewallSubnet', 'vnet-I/AzureFirewallSubnet';

            $ruleResult[0].Reason | Should -BeExactly @(
                "The firewall should have a NAT gateway associated."
                "The firewall should have a NAT gateway associated."
            );
            $ruleResult[1].Reason | Should -BeExactly "The firewall should have a NAT gateway associated.";
            $ruleResult[2].Reason | Should -BeExactly "The firewall should have a NAT gateway associated.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E', 'vnet-F', 'vnet-G', 'vnet-H/excludedSubnet', 'vnet-J/AzureFirewallSubnet', 'vnet-H/subnet-A', 'vnet-H/subnet-B', 'vnet-H/subnet-C';
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E';
            $ruleResult.Length | Should -Be 4;
            
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
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-F', 'vnet-G', 'vnet-H/AzureFirewallSubnet', 'vnet-I/AzureFirewallSubnet', 'vnet-H/excludedSubnet', 'vnet-J/AzureFirewallSubnet', 'vnet-H/subnet-A', 'vnet-H/subnet-B', 'vnet-H/subnet-C';
        }
    }
}
