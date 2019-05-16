#
# Unit tests for Azure subscription rules
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

Describe 'Azure.Subscription' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Subscription.json';

    Context 'Conditions' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -WarningAction Ignore;

        It 'Azure.Subscription.SecurityCenterContact' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Subscription.SecurityCenterContact' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-C';
        }

        It 'Azure.Subscription.SecurityCenterProvisioning' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Subscription.SecurityCenterProvisioning' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-A';
        }
    }
}
