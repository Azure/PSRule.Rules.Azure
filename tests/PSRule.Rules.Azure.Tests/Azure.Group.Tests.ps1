# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure resource group rules
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

Describe 'Azure.Group' -Tag 'ResourceGroup', 'Group' {
    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_RESOURCE_GROUP_NAME_FORMAT' = '^rg-' };

            $names = @(
                'rg'
                'rg-'
                'RG-'
                'rg-test'
                'rg_'
                'rg(1)'
                'group.'
                'resourceGroup.1'

                # Managed resource groups
                'NetworkWatcherRG'
                'AzureBackupRG_eastus'
                'DefaultResourceGroup-eus'
                'cloud-shell-storage-eastus'
                'MC_app-kubernetes-cluster-1'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Resources/resourceGroups'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.Group.Name','Azure.Group.Naming'
        }

        It 'Azure.Group.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Group.Name' };
            $validNames = @(
                'rg'
                'rg-'
                'RG-'
                'rg-test'
                'rg_'
                'rg(1)'
                'resourceGroup.1'
                'NetworkWatcherRG'
                'AzureBackupRG_eastus'
                'DefaultResourceGroup-eus'
                'cloud-shell-storage-eastus'
                'MC_app-kubernetes-cluster-1'
            )

            $invalidNames = @(
                'group.'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }

        It 'Azure.Group.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Group.Naming' };
            $validNames = @(
                'rg-test'
                'rg-'
            )

            $invalidNames = @(
                'group.'
                'rg'
                'RG-'
                'rg_'
                'rg(1)'
                'resourceGroup.1'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }
    }
}
