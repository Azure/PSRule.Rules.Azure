# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Virtual Network rules
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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
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
            $ruleResult.Reason | Should -BeLike 'The subnet (*) has no NSG associated.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-E';
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-C', 'vnet-D', 'vnet-E';
        }

        It 'Azure.VNET.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'vnet-B', 'vnet-D', 'vnet-E';

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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vnet-D', 'vnet-E';
        }

        It 'Azure.VNET.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E';
        }

        It 'Azure.VNET.SubnetName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.SubnetName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vnet-A', 'vnet-B', 'vnet-C', 'vnet-D', 'vnet-E';
        }
    }

    Context 'Resource name - Azure.VNET.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
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
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualNetwork.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop -Culture 'en-US';
        }

        It 'Azure.VNET.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNET.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vnet-001/subnet2';
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
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
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
}

Describe 'Azure.LB' -Tag 'Network', 'LB' {
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

        It 'Azure.LB.Probe' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.LB.Probe' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'lb-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'kubernetes', 'lb-A';
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/loadBalancers'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'lb-001'
                'lb-001_'
                'LB.001'
                'l'
            )

            $invalidNames = @(
                '_lb-001'
                '-lb-001'
                'lb-001-'
                'lb-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.LB.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.LB.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}

Describe 'Azure.Route' -Tag 'Network', 'Route' {
    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/routeTables'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'rt-001'
                'rt-001_'
                'RT.001'
                'r'
            )

            $invalidNames = @(
                '_rt-001'
                '-rt-001'
                'rt-001-'
                'rt-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Route.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Route.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-C', 'nsg-D', 'nsg-E';
        }

        It 'Azure.NSG.DenyAllInbound' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.DenyAllInbound' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-B', 'nsg-D', 'nsg-E';
        }

        It 'Azure.NSG.LateralTraversal' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.NSG.LateralTraversal' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nsg-C';

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
            $ruleResult.Reason | Should -BeLike 'The resource is not associated.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-A';
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/networkSecurityGroups'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'nsg-001'
                'nsg-001_'
                'NSG.001'
                'n'
            )
            $invalidNames = @(
                '_nsg-001'
                '-nsg-001'
                'nsg-001-'
                'nsg-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.NSG.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.NSG.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
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

Describe 'Azure.Firewall' -Tag 'Network', 'Firewall' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Firewall.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.Firewall.Mode' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Firewall.Mode' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'firewall-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'firewall-B';
        }
    }
}

Describe 'Azure.VNG' -Tag 'Network', 'VNG', 'VPN', 'ExpressRoute' {
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

        It 'Azure.VNG.VPNLegacySKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.VPNLegacySKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-B';
        }

        It 'Azure.VNG.VPNActiveActive' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.VPNActiveActive' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-B';
        }

        It 'Azure.VNG.ERLegacySKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.ERLegacySKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-C';
        }
    }

    Context 'Resource name - Azure.VNG.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/virtualNetworkGateways'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'vng-001'
                'vng-001_'
                'VNG.001'
                'v'
            )
            $invalidNames = @(
                '_vng-001'
                '-vng-001'
                'vng-001-'
                'vng-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNG.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNG.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.VNG.ConnectionName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/connections'
            }    
        }

        BeforeDiscovery {
            $validNames = @(
                'cn-001'
                'cn-001_'
                'CN.001'
                'c'
            )

            $invalidNames = @(
                '_cn-001'
                '-cn-001'
                'cn-001-'
                'cn-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNG.ConnectionName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VNG.ConnectionName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With template - VPN' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VPN.json;
            Get-AzRuleTemplateLink -Path $here -InputPath 'Resources.VPN.Parameters.json' | Export-AzRuleTemplateData -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.VNG.VPNLegacySKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.VPNLegacySKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-A';
        }

        It 'Azure.VNG.VPNActiveActive' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.VPNActiveActive' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }
    }

    Context 'With template - ExpressRoute' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.ExpressRoute.json;
            Get-AzRuleTemplateLink -Path $here -InputPath 'Resources.ExpressRoute.Parameters.json' | Export-AzRuleTemplateData -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.VNG.ERLegacySKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VNG.ERLegacySKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gateway-A';
        }
    }
}
