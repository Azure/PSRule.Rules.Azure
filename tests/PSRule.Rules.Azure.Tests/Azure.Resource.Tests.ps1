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
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -Option $options -InputPath $dataPath -WarningAction Ignore;

        It 'Azure.Resource.UseTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Resource.UseTags' };

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
        }
    }
}
