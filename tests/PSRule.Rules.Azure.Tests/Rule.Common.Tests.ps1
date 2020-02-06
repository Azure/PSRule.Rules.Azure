# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for PSRule rule quality
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

Describe 'Rule quality' {
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.All' -WarningAction SilentlyContinue;

    Context 'Naming' {
        foreach ($rule in $rules) {
            It $rule.RuleName {
                $rule.RuleName | Should -BeLike "Azure*";
                # $rule.RuleName.Length -le 35 | Should -Be $True;
                if ($rule.RuleName.Length -gt 35) {
                    Write-Warning -Message "Rule name $($rule.RuleName) is longer than 35 characters.";
                }
            }
        }
    }

    Context 'Metadata' {
        foreach ($rule in $rules) {
            It $rule.RuleName {
                $rule.Synopsis | Should -Not -BeNullOrEmpty;
                $rule.Description | Should -Not -BeNullOrEmpty;
                $rule.Tag.release | Should -BeIn 'GA', 'preview';
                $rule.Info.Annotations.severity | Should -Not -BeNullOrEmpty;
                $rule.Info.Annotations.category | Should -Not -BeNullOrEmpty;
                $rule.Info.GetOnlineHelpUri()  | Should -Not -BeNullOrEmpty;
            }
        }
    }
}
