#
# CI script for integration with Azure DevOps
#

[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)]
    [String]$File,

    [Parameter(Mandatory = $False)]
    [String]$Task,

    [Parameter(Mandatory = $False)]
    [String]$ModuleVersion,

    [Parameter(Mandatory = $False)]
    [AllowNull()]
    [String]$ReleaseVersion,

    [Parameter(Mandatory = $False)]
    [String]$Configuration,

    [Parameter(Mandatory = $False)]
    [String]$NuGetApiKey,

    [Parameter(Mandatory = $False)]
    [Switch]$CodeCoverage = $False,

    [Parameter(Mandatory = $False)]
    [String]$ArtifactPath
)

if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue';
}

if ($Null -eq (Get-PackageProvider -Name NuGet -ErrorAction Ignore)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
}

if ($Null -eq (Get-InstalledModule -Name PowerShellGet -MinimumVersion 2.1.2 -ErrorAction Ignore)) {
    Install-Module PowerShellGet -MinimumVersion 2.1.2 -Scope CurrentUser -Force -AllowClobber;
    Import-Module PowerShellGet -MinimumVersion 2.1.2 -Force;
}

if ($Null -eq (Get-InstalledModule -Name InvokeBuild -MinimumVersion 5.4.0 -ErrorAction Ignore)) {
    Install-Module InvokeBuild -MinimumVersion 5.4.0 -Scope CurrentUser -Force;
}

Invoke-Build @PSBoundParameters
