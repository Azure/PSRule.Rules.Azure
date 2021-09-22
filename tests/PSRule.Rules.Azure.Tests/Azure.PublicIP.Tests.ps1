# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Public IP address rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.PublicIP' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.PublicIP.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.PublicIP.IsAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.IsAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'ip-B', 'Ip-C', 'ip-D', 'ip-E', 'ip-F', 'ip-G', 'ip-H', 'ip-I', 'ip-J', 'ip-K';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';
        }

        It 'Azure.PublicIP.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -Be 'ip-A', 'ip-B', 'Ip-C', 'ip-D', 'ip-E', 'ip-F', 'ip-G', 'ip-H', 'ip-I', 'ip-J', 'ip-K';
        }

        It 'Azure.PublicIP.DNSLabel' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.DNSLabel' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'ip-B', 'Ip-C', 'ip-D', 'ip-E', 'ip-F', 'ip-G', 'ip-H', 'ip-I', 'ip-J', 'ip-K';
        }

        It 'Azure.PublicIP.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'ip-B', 'ip-D', 'ip-G';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The public IP (ip-B) deployed to region (australiaeast) should be zone-redundant."
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The public IP (ip-D) deployed to region (australiaeast) should be zone-redundant."
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The public IP (ip-G) deployed to region (australiaeast) should be zone-redundant."

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -Be 'ip-C', 'ip-E', 'ip-F', 'ip-H', 'ip-I', 'ip-J', 'ip-K';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';
        }

        It 'Azure.PublicIP.StandardSKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.StandardSKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The field 'sku.name' is set to 'Basic'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'ip-B', 'ip-C', 'ip-D', 'ip-E', 'ip-F', 'ip-G', 'ip-H', 'ip-I', 'ip-J', 'ip-K';
        }
    }

    Context 'Resource name -- Azure.PublicIP.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Network/publicIPAddresses'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'pip-001'
                'pip-001_'
                'PIP.001'
                'p'
            )

            $invalidNames = @(
                '_pip-001'
                '-pip-001'
                'pip-001-'
                'pip-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PublicIP.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PublicIP.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name -- Azure.PublicIP.DNSLabel' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                ResourceType = 'Microsoft.Network/publicIPAddresses'
                Properties = [PSCustomObject]@{
                    dnsSettings = [PSCustomObject]@{
                        domainNameLabel = ''
                    }
                }
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'pip-001'
                'pip'
            )

            $invalidNames = @(
                'PIP-001'
                '_pip-001'
                '-pip-001'
                'pip.001'
                'pip-001-'
                'pip-001.'
                'pip-001_'
                'p'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Properties.dnsSettings.domainNameLabel = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PublicIP.DNSLabel';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Properties.dnsSettings.domainNameLabel = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PublicIP.DNSLabel';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template3.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.PublicIP.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.PublicIP.IsAttached' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.PublicIP.IsAttached' -and
                $_.TargetType -eq 'Microsoft.Network/publicIPAddresses'
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
            $ruleResult.TargetName | Should -Be 'pip-001';
        }

        It 'Azure.PublicIP.Name' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.PublicIP.Name' -and
                $_.TargetType -eq 'Microsoft.Network/publicIPAddresses'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'pip-001';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.PublicIP.DNSLabel' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.PublicIP.DNSLabel' -and
                $_.TargetType -eq 'Microsoft.Network/publicIPAddresses'
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
            $ruleResult.TargetName | Should -Be 'pip-001';
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
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.PublicIP.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.PublicIP.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
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
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'ip-B', 'ip-D', 'ip-F', 'ip-G', 'ip-H', 'ip-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The public IP (ip-B) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The public IP (ip-D) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The public IP (ip-F) deployed to region (australiasoutheast) should be zone-redundant.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The public IP (ip-G) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The public IP (ip-H) deployed to region (Australia Southeast) should be zone-redundant.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The public IP (ip-J) deployed to region (Norway East) should be zone-redundant.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'ip-C', 'ip-E', 'ip-I', 'ip-K';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';
        }

        It 'Azure.PublicIP.AvailabilityZone - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'ip-B', 'ip-D', 'ip-F', 'ip-G', 'ip-H', 'ip-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The public IP (ip-B) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The public IP (ip-D) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The public IP (ip-F) deployed to region (australiasoutheast) should be zone-redundant.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The public IP (ip-G) deployed to region (australiaeast) should be zone-redundant.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The public IP (ip-H) deployed to region (Australia Southeast) should be zone-redundant.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The public IP (ip-J) deployed to region (Norway East) should be zone-redundant.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'ip-C', 'ip-E', 'ip-I', 'ip-K';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';
        }
    }
}
