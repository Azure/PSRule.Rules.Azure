#
# Unit tests for baselines
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

Describe 'Baselines' -Tag Baseline {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Resource.json';

    Context 'Binding' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -Outcome All -InputPath $dataPath -WarningAction Ignore -ErrorAction Stop;

        It 'TargetType' {
            $result.TargetType | Should -Not -BeIn 'System.Management.Automation.PSCustomObject';
        }
    }
}
