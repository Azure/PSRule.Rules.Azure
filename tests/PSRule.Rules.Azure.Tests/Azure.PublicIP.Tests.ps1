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
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.PublicIP.IsAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.IsAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-B';

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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'ip-A', 'ip-B';
        }

        It 'Azure.PublicIP.DNSLabel' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.DNSLabel' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-B';
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
}
