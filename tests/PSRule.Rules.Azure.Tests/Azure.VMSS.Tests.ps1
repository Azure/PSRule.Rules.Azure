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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002', 'vmss-003', 'vmss-004', 'vmss-005';
        }

        It 'Azure.VMSS.ComputerName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.ComputerName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002', 'vmss-003', 'vmss-004', 'vmss-005';
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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-005';
        }

        It 'Azure.VMSS.MigrateAMA' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.MigrateAMA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-002', 'vmss-004', 'vmss-005';

            $ruleResult[0].Reason | Should -BeExactly "The legacy Log Analytics Agent is deprecated and will be retired on August 31, 2024. Migrate to the Azure Monitor Agent.";
            $ruleResult[1].Reason | Should -BeExactly "The legacy Log Analytics Agent is deprecated and will be retired on August 31, 2024. Migrate to the Azure Monitor Agent.";
            $ruleResult[2].Reason | Should -BeExactly "The legacy Log Analytics Agent is deprecated and will be retired on August 31, 2024. Migrate to the Azure Monitor Agent.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-003';
        }

        It 'Azure.VMSS.AMA' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.AMA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-002', 'vmss-004', 'vmss-005';

            $ruleResult[0].Reason | Should -BeExactly "The virtual machine scale set should have Azure Monitor Agent installed.";
            $ruleResult[1].Reason | Should -BeExactly "The virtual machine scale set should have Azure Monitor Agent installed.";
            $ruleResult[2].Reason | Should -BeExactly "The virtual machine scale set should have Azure Monitor Agent installed.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-003';
        }

        It 'Azure.VMSS.AutoInstanceRepairs' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.AutoInstanceRepairs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.automaticRepairsPolicy.enabled: The field 'properties.automaticRepairsPolicy.enabled' does not exist.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.automaticRepairsPolicy.enabled: Is set to 'False'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-003', 'vmss-004', 'vmss-005';
        }
        
        It 'Azure.VMSS.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-002';

            $ruleResult[0].Reason | Should -BeExactly 'The virtual machine scale set (vmss-001) deployed to region (eastus) should use a minimum of two availability zones from the following [1, 2, 3].';
            $ruleResult[1].Reason | Should -BeExactly 'The virtual machine scale set (vmss-002) deployed to region (eastus) should use a minimum of two availability zones from the following [1, 2, 3].';
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-003', 'vmss-004', 'vmss-005';
        }
        
        It 'Azure.VMSS.ZoneBalance' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.ZoneBalance' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vmss-002';

            $ruleResult[0].Reason | Should -BeExactly "The field 'properties.zoneBalance' is set to 'True'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vmss-001', 'vmss-004', 'vmss-005';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vmss-003', 'vmss-006/instance-A', 'vmss-006/instance-B', 'nic-A', 'nic-B';
        }

        It 'Azure.VMSS.PublicIPAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.PublicIPAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'vmss-001', 'vmss-002', 'vmss-006/instance-A', 'nic-A';

            $ruleResult[0].Reason | Should -BeExactly "The virtual machine scale set instances should not have public IP addresses directly attached to their network interfaces.";
            $ruleResult[1].Reason | Should -BeExactly "The virtual machine scale set instances should not have public IP addresses directly attached to their network interfaces.";
            $ruleResult[2].Reason | Should -BeExactly "The virtual machine scale set instances should not have public IP addresses directly attached to their network interfaces.";
            $ruleResult[3].Reason | Should -BeExactly "The virtual machine scale set instances should not have public IP addresses directly attached to their network interfaces.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'vmss-003', 'vmss-004', 'vmss-005', 'vmss-006/instance-B', 'nic-B';
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
    }

    Context 'Linux offers - Azure.VMSS.PublicKey' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'
                Type = 'Microsoft.Compute/virtualMachineScaleSets'
                Properties = [PSCustomObject]@{
                    virtualMachineProfile = [PSCustomObject]@{
                        storageProfile = [PSCustomObject]@{
                            imageReference = [PSCustomObject]@{
                                publisher = ''
                                offer = ''
                            }
                        }
                    }
                }
            }
        }

        BeforeDiscovery {
            $validImages = @(
                @{ publisher = "Canonical"; offer = "UbuntuServer" }
                @{ publisher = "center-for-internet-security-inc"; offer = "cis-centos-7-v2-1-1-l1" }
            )

            $invalidImages = @(
                @{ publisher = "center-for-internet-security-inc"; offer = "cis-windows-server-2019-v1-0-0-l1" }
            )
        }

        # Pass
        It '<_>' -ForEach $validImages {
            $testObject.Properties.virtualMachineProfile.storageProfile.imageReference.publisher = $_.publisher;
            $testObject.Properties.virtualMachineProfile.storageProfile.imageReference.offer = $_.offer;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VMSS.PublicKey';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -BeIn 'Pass', 'Fail';
        }

        # Fail
        It '<_>' -ForEach $invalidImages {
            $testObject.Properties.virtualMachineProfile.storageProfile.imageReference.publisher = $_.publisher;
            $testObject.Properties.virtualMachineProfile.storageProfile.imageReference.offer = $_.offer;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Outcome All -Name 'Azure.VMSS.PublicKey';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'None';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.VMSS.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.VMSS.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VMSS.template.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
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
}
