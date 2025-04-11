# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure resource rules
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

Describe 'Azure.Resource' -Tag 'Resource' {
    Context 'Conditions' {
        BeforeAll {
            $option = New-PSRuleOption -BaselineConfiguration @{ 'Azure_AllowedRegions' = @('region-A') };
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                Option        = $option
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Resource.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

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
            $ruleResult[0].Reason | Should -BeExactly "Path location: The location 'region-B' is not in the allowed set of resource locations.";
            $ruleResult[0].Detail.Reason.Path | Should -Be 'location';

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
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Resource.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $option = New-PSRuleOption -BaselineConfiguration @{ 'AZURE_RESOURCE_ALLOWED_LOCATIONS' = @('region-A') };
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                Option        = $option
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'route-subnet1', 'route-subnet2', 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 2;
            $ruleResult[0].Reason | Should -Be @(
                'The resource is not tagged.', 
                "Path tags: Does not exist."
            );
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -HaveCount 2;
            $ruleResult[1].Reason | Should -Be @(
                'The resource is not tagged.', 
                "Path tags: Does not exist."
            );
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -HaveCount 2;
            $ruleResult[2].Reason | Should -Be @(
                'The resource is not tagged.', 
                "Path tags: Does not exist."
            );
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -HaveCount 2;
            $ruleResult[3].Reason | Should -Be @(
                'The resource is not tagged.', 
                "Path tags: Does not exist."
            );
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -HaveCount 2;
            $ruleResult[4].Reason | Should -Be @(
                'The resource is not tagged.', 
                "Path tags: Does not exist."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetType | Should -BeIn 'Microsoft.Resources/deployments';
        }

        It 'Azure.Resource.AllowedRegions' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.AllowedRegions' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'route-subnet1', 'route-subnet2', 'nsg-subnet1', 'nsg-subnet2', 'nsg-extra';
            $ruleResult[0].Reason | Should -BeExactly "Path location: The location 'eastus' is not in the allowed set of resource locations.";
            $ruleResult[1].Reason | Should -BeExactly "Path location: The location 'eastus' is not in the allowed set of resource locations.";
            $ruleResult[2].Reason | Should -BeExactly "Path location: The location 'eastus' is not in the allowed set of resource locations.";
            $ruleResult[3].Reason | Should -BeExactly "Path location: The location 'eastus' is not in the allowed set of resource locations.";
            $ruleResult[4].Reason | Should -BeExactly "Path location: The location 'eastus' is not in the allowed set of resource locations.";
            $ruleResult[0..4].Detail.Reason.Path | Should -BeIn @('location');

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vnet-001';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetType | Should -BeIn 'Microsoft.Resources/deployments';
        }
    }
}
