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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'appgw-B', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';

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

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.UseWAF' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.UseWAF' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'appgw-B', 'appgw-F', 'appgw-G';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E';
        }

        It 'Azure.AppGw.SSLPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.SSLPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-B', 'appgw-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.Prevention' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.Prevention' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.WAFEnabled' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.WAFEnabled' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.OWASP' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.OWASP' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'appgw-A';

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

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-E', 'appgw-F', 'appgw-G';
        }

        It 'Azure.AppGw.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-E', 'appgw-F';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'appgw-C', 'appgw-D', 'appgw-G';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'appgw-A', 'appgw-B';
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
                        Location = 'Australia Southeast'
                        Zones = @("1", "2", "3")
                    }
                    [PSCustomObject]@{
                        Location = 'Norway East'
                        Zones = @("1", "2", "3")
                    }
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppGw.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 4;
            $ruleResult.TargetName | Should -BeIn 'appgw-C', 'appgw-E', 'appgw-F', 'appgw-G';

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
            $ruleResult | Should -HaveCount 4;
            $ruleResult.TargetName | Should -BeIn 'appgw-C', 'appgw-E', 'appgw-F', 'appgw-G';

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
}
