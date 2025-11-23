# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Event Hub rules
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

Describe 'Azure.EventHub' -Tag 'EventHub' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.EventHub.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.EventHub.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'hubns-B', 'hubns-C', 'hubns-D', 'hubns-E', 'hubns-F', 'hubns-G', 'hubns-H';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'hubns-A';
        }

        It 'Azure.EventHub.Usage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.Usage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'hubns-B', 'hubns-C', 'hubns-D', 'hubns-E', 'hubns-F', 'hubns-G', 'hubns-H';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'hubns-A';
        }

        It 'Azure.EventHub.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'hubns-A', 'hubns-B';
            $ruleResult[0].Reason | Should -BeExactly "Path properties.minimumTlsVersion: The field 'properties.minimumTlsVersion' does not exist.";
            $ruleResult[1].Reason | Should -BeLike "Path properties.minimumTlsVersion: The version '1.1.*' does not match the constraint *";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'hubns-C', 'hubns-D', 'hubns-E', 'hubns-F', 'hubns-G', 'hubns-H';
        }

        It 'Azure.EventHub.Firewall' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.Firewall' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'hubns-B', 'hubns-C', 'hubns-D', 'hubns-X/default-A';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.publicNetworkAccess: Does not exist.";
            $ruleResult[1].Reason | Should -BeIn "Path properties.publicNetworkAccess: Is set to 'Enabled'.";
            $ruleResult[2..3].Reason | Should -BeIn "Path properties.publicNetworkAccess: Is set to 'Enabled'.", "Path properties.defaultAction: Is set to 'Allow'."

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'hubns-E', 'hubns-F', 'hubns-Y/default-B', 'default-C', 'default-D', 'hubns-G', 'hubns-H';
        }

        It 'Azure.EventHub.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'hubns-A', 'hubns-B';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.zoneRedundant: Does not exist.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.zoneRedundant: Is set to 'False'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'hubns-C', 'hubns-D', 'hubns-E', 'hubns-F', 'hubns-G', 'hubns-H';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.EventHub.json;
            Export-AzRuleTemplateData -TemplateFile (Join-Path -Path $here -ChildPath 'Resources.EventHub.Template.json') -OutputPath $outputFile;
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.EventHub.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventHub.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'hubns-001';
        }
    }
}
