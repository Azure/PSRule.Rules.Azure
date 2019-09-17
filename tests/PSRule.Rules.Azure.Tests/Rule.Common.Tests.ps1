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
    Context 'Metadata' {
        $result = Get-PSRule -Module PSRule.Rules.Azure -WarningAction Ignore;

        foreach ($rule in $result) {
            It $rule.RuleName {
                $rule.Description | Should -Not -BeNullOrEmpty;
                $rule.Info.Annotations.severity | Should -Not -BeNullOrEmpty;
                $rule.Info.Annotations.category | Should -Not -BeNullOrEmpty;

                if ($rule.RuleName.Length -gt 35) {
                    Write-Warning -Message "Rule name $($rule.RuleName) if longer than 35 characters.";
                }
            }
        }
    }
}
