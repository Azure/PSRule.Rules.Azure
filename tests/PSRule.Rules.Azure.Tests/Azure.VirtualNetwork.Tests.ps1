#
# Unit tests for Azure Virtual Network rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.VirtualNetwork' -Tag 'Network' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualNetwork.json';

    Context 'Conditions' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.VirtualNetwork.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'vnet-B', 'vnet-C', 'vnet-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-A';
        }

        It 'Azure.VirtualNetwork.SingleDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.SingleDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-C', 'vnet-D';
        }

        It 'Azure.VirtualNetwork.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vnet-B', 'vnet-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vnet-A', 'vnet-C';
        }

        It 'Azure.VirtualNetwork.PeerState' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.PeerState' };

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
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-D';
        }

        It 'Azure.VirtualNetwork.NSGAnyInboundSource' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGAnyInboundSource' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'nsg-A', 'nsg-C';
        }

        It 'Azure.VirtualNetwork.NSGDenyAllInbound' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGDenyAllInbound' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'nsg-A', 'nsg-B';
        }

        It 'Azure.VirtualNetwork.LateralTraversal' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.LateralTraversal' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nsg-A', 'nsg-B';
        }

        It 'Azure.VirtualNetwork.NSGAssociated' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGAssociated' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'nsg-B', 'nsg-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-A';
        }

        It 'Azure.VirtualNetwork.AppGwMinInstance' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwMinInstance' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwMinSku' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwMinSku' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwUseWAF' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwUseWAF' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwSSLPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwSSLPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-B', 'appgw-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-A';
        }

        It 'Azure.VirtualNetwork.AppGwPrevention' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwPrevention' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwWAFEnabled' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwWAFEnabled' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwOWASP' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwOWASP' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-C';
        }

        It 'Azure.VirtualNetwork.AppGwWAFRules' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.AppGwWAFRules' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-A';
        }

        It 'Azure.VirtualNetwork.NICAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NICAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nic-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nic-A';
        }

        It 'Azure.VirtualNetwork.LBProbe' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.LBProbe' };

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

    Context 'With Template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
        $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualNetwork.json;
        Export-AzTemplateRuleData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.VirtualNetwork.UseNSGs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.UseNSGs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
        }

        It 'Azure.VirtualNetwork.SingleDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.SingleDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
        }

        It 'Azure.VirtualNetwork.LocalDNS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.LocalDNS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';
        }

        It 'Azure.VirtualNetwork.PeerState' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.PeerState' };

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

        It 'Azure.VirtualNetwork.NSGAnyInboundSource' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGAnyInboundSource' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'nsg-subnet1', 'nsg-subnet2';
        }

        It 'Azure.VirtualNetwork.NSGDenyAllInbound' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGDenyAllInbound' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-subnet1';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-subnet2';
        }

        It 'Azure.VirtualNetwork.LateralTraversal' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.LateralTraversal' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-subnet2';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nsg-subnet1';
        }

        It 'Azure.VirtualNetwork.NSGAssociated' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualNetwork.NSGAssociated' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.Network/networkSecurityGroups' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'nsg-subnet1', 'nsg-subnet2';
        }
    }
}
