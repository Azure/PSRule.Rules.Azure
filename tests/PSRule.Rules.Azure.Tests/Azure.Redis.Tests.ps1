# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Redis Cache rules
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

Describe 'Azure.Redis' -Tag 'Redis' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Redis.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.Redis.NonSslPort' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.NonSslPort' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'redis-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-Q', 'redis-R', 'redis-S';
        }

        It 'Azure.Redis.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'redis-B', 'redis-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-C', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';
        }

        It 'Azure.RedisEnterprise.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RedisEnterprise.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'redis-K', 'redis-L';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-S';
        }

        It 'Azure.Redis.MinSKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.MinSKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -BeIn 2;
            $ruleResult.TargetName | Should -Be 'redis-C', 'redis-Q';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J';
        }

        It 'Azure.Redis.MaxMemoryReserved' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.MaxMemoryReserved' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'redis-D', 'redis-Q';

             # None
             $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
             $ruleResult | Should -Not -BeNullOrEmpty;
             $ruleResult.Length | Should -Be 8;
             $ruleResult.TargetName | Should -BeIn 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-R', 'redis-S';
        }

        It 'Azure.Redis.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'redis-F', 'redis-G', 'redis-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The premium redis cache (redis-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The premium redis cache (redis-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The premium redis cache (redis-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'redis-E', 'redis-H', 'redis-I';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 13;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-Q', 'redis-R', 'redis-S';
        }

        It 'Azure.RedisEnterprise.Zones' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RedisEnterprise.Zones' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'redis-L', 'redis-P', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The enterprise redis cache (redis-L) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The enterprise redis cache (redis-P) deployed to region (australiaeast) should be zone-redundant.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'redis-K', 'redis-M', 'redis-N', 'redis-O';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 12;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';
        }

        It 'Azure.Redis.PublicNetworkAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.PublicNetworkAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path properties.publicNetworkAccess: Is set to 'Enabled'.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -BeExactly "Path properties.publicNetworkAccess: The field 'properties.publicNetworkAccess' does not exist.";
            $ruleResult[8].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[8].Reason | Should -BeExactly "Path properties.publicNetworkAccess: Is set to 'Enabled'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-F';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-S';
        }

        It 'Azure.Redis.FirewallRuleCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.FirewallRuleCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'redis-C', 'redis-E', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of firewall rules (11) exceeded 10.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The number of firewall rules (11) exceeded 10.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'redis-B', 'redis-D';

            # None 
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-F', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-S';
        }

        It 'Azure.Redis.FirewallIPRange' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.FirewallIPRange' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'redis-E', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of public IP addresses permitted (11) exceeded 10.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.Cache/redis/firewallRules' has not been specified.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'redis-B', 'redis-C', 'redis-D';

            # None 
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-F', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-S';
        }

        It 'Azure.Redis.Version' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Cache for Redis should use the latest supported version of Redis.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Cache for Redis should use the latest supported version of Redis.";
            $ruleResult[2].Reason | Should -BeExactly "The Azure Cache for Redis should use the latest supported version of Redis.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-Q', 'redis-R';
        }
        

        It 'Azure.Redis.EntraID' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.EntraID' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.redisConfiguration.aad-enabled: The field 'properties.redisConfiguration.aad-enabled' does not exist.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.redisConfiguration.aad-enabled: Is set to ''.";
            $ruleResult[2].Reason | Should -BeExactly "Path properties.redisConfiguration.aad-enabled: Is set to 'False'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';

             # None
             $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
             $ruleResult.Length | Should -Be 7;
             $ruleResult.TargetName | Should -BeIn 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-S';
        }

        It 'Azure.Redis.LocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.LocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q';
            $ruleResult.Length | Should -Be 11;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'redis-R';
            $ruleResult.Length | Should -Be 1;
        }

        It 'Azure.Redis.Retirement' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.Retirement' };

            # Fail - All Azure Cache for Redis instances should fail this rule
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 12;
            $ruleResult.TargetName | Should -BeIn 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';

            # Verify the reason message
            $ruleResult[0].Reason | Should -BeExactly "Azure Cache for Redis is being retired. Migrate to Azure Managed Redis.";
        }
    }

    Context 'With Configuration Option' -Tag 'Configuration' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Redis.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.Redis.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
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
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The premium redis cache (redis-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The premium redis cache (redis-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The premium redis cache (redis-H) deployed to region (Antarctica North) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The premium redis cache (redis-I) deployed to region (antarcticasouth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The premium redis cache (redis-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'redis-E';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 13;
            $ruleResult.TargetName | Should -Be 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-Q', 'redis-R', 'redis-S';
        }

        It 'Azure.Redis.AvailabilityZone - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The premium redis cache (redis-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The premium redis cache (redis-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The premium redis cache (redis-H) deployed to region (Antarctica North) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The premium redis cache (redis-I) deployed to region (antarcticasouth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The premium redis cache (redis-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'redis-E';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 13;
            $ruleResult.TargetName | Should -Be 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-K', 'redis-L', 'redis-M', 'redis-N', 'redis-O', 'redis-P', 'redis-Q', 'redis-R', 'redis-S';
        }

        It 'Azure.RedisEnterprise.Zones - HashTable option' {
            $option = @{
                'Configuration.AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
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
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RedisEnterprise.Zones' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'redis-L', 'redis-M', 'redis-N', 'redis-P', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The enterprise redis cache (redis-L) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The enterprise redis cache (redis-M) deployed to region (Antarctica North) should be zone-redundant.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The enterprise redis cache (redis-N) deployed to region (antarcticasouth) should be zone-redundant.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The enterprise redis cache (redis-P) deployed to region (australiaeast) should be zone-redundant.";
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'redis-K', 'redis-O';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 12;
            $ruleResult.TargetName | Should -Be 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';
        }

        It 'Azure.RedisEnterprise.Zones - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RedisEnterprise.Zones' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'redis-L', 'redis-M', 'redis-N', 'redis-P', 'redis-S';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The enterprise redis cache (redis-L) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The enterprise redis cache (redis-M) deployed to region (Antarctica North) should be zone-redundant.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The enterprise redis cache (redis-N) deployed to region (antarcticasouth) should be zone-redundant.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The enterprise redis cache (redis-P) deployed to region (australiaeast) should be zone-redundant.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'redis-K', 'redis-O';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 12;
            $ruleResult.TargetName | Should -Be 'redis-A', 'redis-B', 'redis-C', 'redis-D', 'redis-E', 'redis-F', 'redis-G', 'redis-H', 'redis-I', 'redis-J', 'redis-Q', 'redis-R';
        }
    }
}
