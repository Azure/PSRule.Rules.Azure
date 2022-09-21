# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Virtual Machine Scale Set rules
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

Describe 'Azure.VMSS' -Tag 'VMSS' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.VMSS.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002', 'vmss-003';
        }

        It 'Azure.VMSS.ComputerName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.ComputerName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002', 'vmss-003';
        }
    }

    Context 'Resource name - Azure.VMSS.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'vmss-001'
                'vmss-001_'
                'VMSS.001'
                '000000'
            )

            $invalidNames = @(
                '_vmss-001'
                '-vmss-001'
                'vmss-001-'
                'vmss-001.'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.VMSS.ComputerName (Windows)' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'
                Properties = [PSCustomObject]@{
                    virtualMachineProfile = [PSCustomObject]@{
                        storageProfile = [PSCustomObject]@{
                            osDisk = [PSCustomObject]@{
                                osType = 'Windows'
                            }
                        }
                        osProfile = [PSCustomObject]@{
                            computerNamePrefix = ''
                        }
                    }
                }
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'vmss-001'
                '-vmss-001-'
                'v'
                'virtualMachine1'
                'v00000'
            )

            $invalidNames = @(
                'vmss_001'
                'vmss.001'
                '0000000'
                'virtualMachine01'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.VMSS.ComputerName (Linux)' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'
                Properties = [PSCustomObject]@{
                    virtualMachineProfile = [PSCustomObject]@{
                        storageProfile = [PSCustomObject]@{
                            osDisk = [PSCustomObject]@{
                                osType = 'Linux'
                            }
                        }
                        osProfile = [PSCustomObject]@{
                            computerNamePrefix = ''
                        }
                    }
                }
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'vmss-001'
                'VMSS.001'
                '000000'
                'vmss-001-'
                'vmss-001.'
                'v'
                'virtualMachine01'
            )

            $invalidNames = @(
                'vmss_001'
                '-vmss-001'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }

        It 'Azure.VMSS.PublicKey' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.PublicKey' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-002', 'vmss-003';

            $ruleResult[0].Reason | Should -BeExactly "The virtual machine scale set 'vmss-002' should have password authentication disabled.";
            $ruleResult[1].Reason | Should -BeExactly "The virtual machine scale set 'vmss-003' should have password authentication disabled.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vmss-001';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.VMSS.Template.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VMSS.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.VMSS.ScriptExtensions' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.ScriptExtensions' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-003', 'vmss-004'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002';

        }
}
