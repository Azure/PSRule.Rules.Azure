#
# Unit tests for Azure template and parameters
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

Describe 'Azure.File' {
    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'SilentlyContinue'
            ErrorAction = 'Stop'
        }
        It 'Azure.File.Template' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Get-Item -Path $dataPath | Invoke-PSRule @invokeParams -Name 'Azure.File.Template';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.File.Template' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Template2.json";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Template.json";
        }

        It 'Azure.File.Parameters' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Parameters*.json';
            $result = Get-Item -Path $dataPath | Invoke-PSRule @invokeParams -Name 'Azure.File.Parameters';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.File.Parameters' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Parameters2.json";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Parameters.json";
        }
    }
}
