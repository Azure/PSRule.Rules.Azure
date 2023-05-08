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

Describe 'Azure.AppGW' -Tag 'Network', 'AppGw' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppGw.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.AppGw.MinInstance' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.MinInstance' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'appgw-B', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.sku.capacity', 'Properties.autoscaleConfiguration.minCapacity';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'appgw-A', 'appgw-C';
        }

        It 'Azure.AppGw.MinSku' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.MinSku' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.sku.name';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
        }

        It 'Azure.AppGw.UseWAF' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.UseWAF' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'appgw-F', 'appgw-G';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.sku.tier';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'appgw-A', 'appgw-B', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-H';
        }

        It 'Azure.AppGw.SSLPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.SSLPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-B', 'appgw-C';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.sslPolicy.policyName', 'Properties.sslPolicy.minProtocolVersion';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
        }

        It 'Azure.AppGw.Prevention' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.Prevention' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'appgw-C';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.webApplicationFirewallConfiguration.firewallMode';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'appgw-A', 'appgw-D', 'appgw-E';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'appgw-B', 'appgw-H', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.WAFEnabled' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.WAFEnabled' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.webApplicationFirewallConfiguration.enabled', 'properties.firewallPolicy.id';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G',  'appgw-H';
        }

        It 'Azure.AppGw.OWASP' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.OWASP' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-A';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.webApplicationFirewallConfiguration.ruleSetType', 'properties.webApplicationFirewallConfiguration.ruleSetVersion';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-E';
        }

        It 'Azure.AppGw.WAFRules' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.WAFRules' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-C';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.webApplicationFirewallConfiguration.disabledRuleGroups';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-D', 'appgw-E';
        }

        It 'Azure.AppGw.UseHTTPS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.UseHTTPS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.requestRoutingRules[0].properties.redirectConfiguration.id';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
        }

        It 'Azure.AppGw.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-E', 'appgw-F';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'zones';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path zones: The application gateway (appgw-E) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path zones: The application gateway (appgw-F) deployed to region (Australia East) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-G', 'appgw-H';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
        }

        It 'Azure.AppGw.MigrateV2' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.MigrateV2' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.sku.tier';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
        }
    }

    Context 'With Configuration Option' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppGw.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.AppGw.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_APPGW_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
                    [PSCustomObject]@{
                        Location = 'Antarctica North'
                        Zones = @("1", "2", "3")
                    }
                    [PSCustomObject]@{
                        Location = 'Antarctica South'
                        Zones = @("1", "2", "3")
                    }
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 5;
            $ruleResult.TargetName | Should -BeIn 'appgw-C', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'zones';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path zones: The application gateway (appgw-C) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path zones: The application gateway (appgw-E) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path zones: The application gateway (appgw-F) deployed to region (Australia East) should use following availability zones [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Path zones: The application gateway (appgw-G) deployed to region (antarcticasouth) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 1;
            $ruleResult.TargetName | Should -BeIn 'appgw-D';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
        }

        It 'Azure.AppGw.AvailabilityZone - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 5;
            $ruleResult.TargetName | Should -BeIn 'appgw-C', 'appgw-E', 'appgw-F', 'appgw-G', 'appgw-H';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'zones';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path zones: The application gateway (appgw-C) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path zones: The application gateway (appgw-E) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path zones: The application gateway (appgw-F) deployed to region (Australia East) should use following availability zones [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Path zones: The application gateway (appgw-G) deployed to region (antarcticasouth) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 1;
            $ruleResult.TargetName | Should -BeIn 'appgw-D';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
        }
    }

    Context 'Resource name - Azure.AppGw.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/applicationGateways'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'a'
                'A'
                'a_'
                'A_'
                '1'
                '1_'
                'contoso-001-agw'
                'contoso.001.agw'
                'contoso_001_agw'
                'contoso-001-agw_'
                'contoso.001.agw_'
                'contoso_001_agw_'
                'CONTOSO-001-AGW'
                'contoso.001.AGW'
                'contoso_001_AGW'
                'CONTOSO-001-AGW_'
                'CONTOSO.001.agw_'
                'contoso_001_AGW_'
            )

            $invalidNames = @(
                'a-'
                'A-'
                '_a'
                '_A'
                '-a'
                '-A'
                '_1'
                '-1'
                '-'
                '_'
                '-contoso-001-agw'
                '-contoso-001-agw-'
                '-_contoso-001-agw'
                'CONTOSO-001-AGW.'
                'CONTOSO-001-AGW-'
                'CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-AGW-001'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppGw.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppGw.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}
