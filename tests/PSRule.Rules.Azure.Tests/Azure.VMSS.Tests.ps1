# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Virtual Machine Scale Set rules
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

Describe 'Azure.VMSS' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.VMSS.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vmss-001';
        }

        It 'Azure.VMSS.ComputerName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.ComputerName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vmss-001';
        }
    }

    Context 'Resource name - Azure.VMSS.Name' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
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
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VMSS.ComputerName (Windows)' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
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

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VMSS.ComputerName (Linux)' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
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

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Properties.virtualMachineProfile.osProfile.computerNamePrefix = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }
}
