#
# Unit tests for Azure Public IP address rules
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

Describe 'Azure.PublicIP' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.PublicIP.json';

    Context 'Conditions' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.PublicIP.IsAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PublicIP.IsAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ip-A';
        }
    }
}
