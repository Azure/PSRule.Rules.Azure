#
# Unit tests for validating module for publishing
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
$modulePath = Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure;

Describe 'PSRule.Rules.Azure' -Tag 'PowerShellGallery' {
    Context 'Module' {
        It 'Can be imported' {
            Import-Module $modulePath -Force;
        }
    }

    Context 'Manifest' {
        $manifestPath = (Join-Path -Path $modulePath -ChildPath PSRule.Rules.Azure.psd1);
        $result = Test-ModuleManifest -Path $manifestPath;

        It 'Has required fields' {
            $result.Name | Should -Be 'PSRule.Rules.Azure';
            $result.Description | Should -Not -BeNullOrEmpty;
            $result.LicenseUri | Should -Not -BeNullOrEmpty;
            $result.ReleaseNotes | Should -Not -BeNullOrEmpty;
        }
    }

    Context 'Static analysis' {
        $result = Invoke-ScriptAnalyzer -Path $modulePath;

        $warningCount = ($result | Where-Object { $_.Severity -eq 'Warning' } | Measure-Object).Count;
        $errorCount = ($result | Where-Object { $_.Severity -eq 'Error' } | Measure-Object).Count;

        if ($warningCount -gt 0) {
            Write-Warning -Message "PSScriptAnalyzer reports $warningCount warnings.";
        }

        It 'Has no quality errors' {
            $errorCount | Should -BeLessOrEqual 0;
        }
    }
}
