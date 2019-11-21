#
# Unit tests for Azure resource rules
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

Describe 'Azure.Resource' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Resource.json';

    Context 'Conditions' {
        $options = New-PSRuleOption -BaselineConfiguration @{ 'azureAllowedRegions' = @('region-A') };
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -Option $options -Outcome All -InputPath $dataPath -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'registry-B', 'registry-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'registry-A', 'trafficManager-A';
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
        Export-AzTemplateRuleData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $options = New-PSRuleOption -BaselineConfiguration @{ 'azureAllowedRegions' = @('region-A') };
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -Option $options -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

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
