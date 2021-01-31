# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure resource rules
#

[CmdletBinding()]
param ()

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

Describe 'Azure.Resource' -Tag 'Resource' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Resource.json';

    Context 'Conditions' {
        $option = New-PSRuleOption -BaselineConfiguration @{ 'Azure_AllowedRegions' = @('region-A') };
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            Option = $option
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'registry-B', 'registry-C';
            $ruleResult.Field.subscriptionId | Should -BeIn '00000000-0000-0000-0000-000000000000';
            $ruleResult.Field.resourceGroupName | Should -BeIn 'test-rg';
            $ruleResult.Field.resourceId | Should -Not -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'registry-A', 'trafficManager-A';
            $ruleResult.Field.subscriptionId | Should -BeIn '00000000-0000-0000-0000-000000000000';
            $ruleResult.Field.resourceGroupName | Should -BeIn 'test-rg';
            $ruleResult.Field.resourceId | Should -Not -BeNullOrEmpty;
        }

        It 'Azure.Resource.AllowedRegions' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.AllowedRegions' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'registry-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'registry-A';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'registry-C', 'trafficManager-A';
        }
    }

    Context 'With Template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
        $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Resource.json;
        Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $option = New-PSRuleOption -BaselineConfiguration @{ 'Azure_AllowedRegions' = @('region-A') };
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            Option = $option
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'route-subnet1', 'route-subnet2', 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetType | Should -BeIn 'Microsoft.Network/virtualNetworks/subnets/providers/roleAssignments', 'Microsoft.Network/virtualNetworks/subnets';
        }

        It 'Azure.Resource.AllowedRegions' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.AllowedRegions' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'vnet-001/subnet2', 'route-subnet1', 'route-subnet2', 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetType | Should -BeIn 'Microsoft.Network/virtualNetworks/subnets/providers/roleAssignments';
        }
    }
}

Describe 'Azure.ResourceGroup' -Tag 'ResourceGroup' {
    Context 'Resource name' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'rg'
            'rg-'
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
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Resources/resourceGroups'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ResourceGroup.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ResourceGroup.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }
}
