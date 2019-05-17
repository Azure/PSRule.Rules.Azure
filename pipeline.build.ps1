
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [String]$ModuleVersion,

    [Parameter(Mandatory = $False)]
    [AllowNull()]
    [String]$ReleaseVersion,

    [Parameter(Mandatory = $False)]
    [String]$Configuration = 'Debug',

    [Parameter(Mandatory = $False)]
    [String]$NuGetApiKey,

    [Parameter(Mandatory = $False)]
    [Switch]$CodeCoverage = $False,

    [Parameter(Mandatory = $False)]
    [String]$ArtifactPath = (Join-Path -Path $PWD -ChildPath out/modules)
)

if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue';
}

if ($Env:Coverage -eq 'true') {
    $CodeCoverage = $True;
}

Write-Verbose -Message "[Pipeline] -- PWD: $PWD";
Write-Verbose -Message "[Pipeline] -- ArtifactPath: $ArtifactPath";
Write-Verbose -Message "[Pipeline] -- System.DefaultWorkingDirectory: $($Env:System_DefaultWorkingDirectory)";

# Copy the PowerShell modules files to the destination path
function CopyModuleFiles {

    param (
        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$DestinationPath
    )

    process {
        $sourcePath = Resolve-Path -Path $Path;

        Get-ChildItem -Path $sourcePath -Recurse -File -Include *.ps1,*.psm1,*.psd1,*.ps1xml | Where-Object -FilterScript {
            ($_.FullName -notmatch '(\.(cs|csproj)|(\\|\/)(obj|bin))')
        } | ForEach-Object -Process {
            $filePath = $_.FullName.Replace($sourcePath, $destinationPath);

            $parentPath = Split-Path -Path $filePath -Parent;

            if (!(Test-Path -Path $parentPath)) {
                $Null = New-Item -Path $parentPath -ItemType Directory -Force;
            }

            Copy-Item -Path $_.FullName -Destination $filePath -Force;
        };
    }
}

task VersionModule PSRule, {
    if (![String]::IsNullOrEmpty($ReleaseVersion)) {
        Write-Verbose -Message "[VersionModule] -- ReleaseVersion: $ReleaseVersion";
        $ModuleVersion = $ReleaseVersion;
    }

    if (![String]::IsNullOrEmpty($ModuleVersion)) {
        Write-Verbose -Message "[VersionModule] -- ModuleVersion: $ModuleVersion";

        $version = $ModuleVersion;
        $revision = [String]::Empty;

        Write-Verbose -Message "[VersionModule] -- Using Version: $version";

        if ($version -like '*-*') {
            [String[]]$versionParts = $version.Split('-', [System.StringSplitOptions]::RemoveEmptyEntries);
            $version = $versionParts[0];

            if ($versionParts.Length -eq 2) {
                $revision = $versionParts[1];
            }

            Write-Verbose -Message "[VersionModule] -- Using Revision: $revision";
        }

        # Update module version
        if (![String]::IsNullOrEmpty($version)) {
            Write-Verbose -Message "[VersionModule] -- Updating module manifest ModuleVersion";
            Update-ModuleManifest -Path (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure/PSRule.Rules.Azure.psd1) -ModuleVersion $version;
        }

        # Update pre-release version
        if (![String]::IsNullOrEmpty($revision)) {
            Write-Verbose -Message "[VersionModule] -- Updating module manifest Prerelease";
            Update-ModuleManifest -Path (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure/PSRule.Rules.Azure.psd1) -Prerelease $revision;
        }
    }

    $manifest = Get-Content -Path (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure/PSRule.Rules.Azure.psd1) -Raw;
    $manifest.Replace('RequiredModules = @()', "RequiredModules = @(@{ ModuleName = 'PSRule'; ModuleVersion = '0.5.0' }, @{ ModuleName = 'Az.Accounts'; ModuleVersion = '1.4.0' }, @{ ModuleName = 'Az.StorageSync'; ModuleVersion = '0.8.0' }, @{ ModuleName = 'Az.Security'; ModuleVersion = '0.7.4' }, @{ ModuleName = 'Az.Storage'; ModuleVersion = '1.1.1' }, @{ ModuleName = 'Az.Websites'; ModuleVersion = '1.1.2' }, @{ ModuleName = 'Az.Sql'; ModuleVersion = '1.7.0' })") | Set-Content -Path (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure/PSRule.Rules.Azure.psd1);
}

task ReleaseModule VersionModule, {
    $modulePath = (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure);
    Write-Verbose -Message "[ReleaseModule] -- Checking module path: $modulePath";

    if (!(Test-Path -Path $modulePath)) {
        Write-Error -Message "[ReleaseModule] -- Module path does not exist";
    }
    elseif (![String]::IsNullOrEmpty($NuGetApiKey)) {
        # Publish to PowerShell Gallery
        Publish-Module -Path $modulePath -NuGetApiKey $NuGetApiKey;
    }
}

# Synopsis: Install NuGet provider
task NuGet {
    if ($Null -eq (Get-PackageProvider -Name NuGet -ErrorAction Ignore)) {
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
    }
}

# Synopsis: Install Pester module
task Pester NuGet, {
    if ($Null -eq (Get-InstalledModule -Name Pester -MinimumVersion 4.0.0 -ErrorAction Ignore)) {
        Install-Module -Name Pester -MinimumVersion 4.0.0 -Scope CurrentUser -Force -SkipPublisherCheck;
    }
    Import-Module -Name Pester -Verbose:$False;
}

# Synopsis: Install PSScriptAnalyzer module
task PSScriptAnalyzer NuGet, {
    if ($Null -eq (Get-InstalledModule -Name PSScriptAnalyzer -MinimumVersion 1.17.0 -ErrorAction Ignore)) {
        Install-Module -Name PSScriptAnalyzer -MinimumVersion 1.17.0 -Scope CurrentUser -Force;
    }
    Import-Module -Name PSScriptAnalyzer -Verbose:$False;
}

# Synopsis: Install PSRule
task PSRule NuGet, {
    if ($Null -eq (Get-InstalledModule -Name PSRule -MinimumVersion 0.5.0 -ErrorAction Ignore)) {
        Install-Module -Name PSRule -MinimumVersion 0.5.0 -AllowPrerelease -Scope CurrentUser -Force;
    }
    Import-Module -Name PSRule -Verbose:$False;
}

# Synopsis: Install PSDocs
task PSDocs NuGet, {
    if ($Null -eq (Get-InstalledModule -Name PSDocs -MinimumVersion 0.6.1 -ErrorAction Ignore)) {
        Install-Module -Name PSDocs -MinimumVersion 0.6.1 -AllowPrerelease -Scope CurrentUser -Force;
    }
    Import-Module -Name PSDocs -Verbose:$False;
}

# Synopsis: Install PlatyPS module
task platyPS {
    if ($Null -eq (Get-InstalledModule -Name PlatyPS -MinimumVersion '0.14.0' -ErrorAction Ignore)) {
        Install-Module -Name PlatyPS -Scope CurrentUser -MinimumVersion '0.14.0' -Force;
    }
    Import-Module -Name PlatyPS -Verbose:$False;
}

task CopyModule {
    CopyModuleFiles -Path src/PSRule.Rules.Azure -DestinationPath out/modules/PSRule.Rules.Azure;

    # Copy generated help into module out path
    # $Null = Copy-Item -Path docs/commands/PSRule.Rules.Azure/en-US/* -Destination out/modules/PSrule.Rules.Azure/en-US/;
    # $Null = Copy-Item -Path docs/commands/PSRule.Rules.Azure/en-US/* -Destination out/modules/PSrule.Rules.Azure/en-AU/;
}

# Synopsis: Build modules only
task BuildModule CopyModule

task TestRules PSRule, Pester, PSScriptAnalyzer, {
    # Run Pester tests
    $pesterParams = @{ Path = $PWD; OutputFile = 'reports/pester-unit.xml'; OutputFormat = 'NUnitXml'; PesterOption = @{ IncludeVSCodeMarker = $True }; PassThru = $True; };

    if (!(Test-Path -Path reports)) {
        $Null = New-Item -Path reports -ItemType Directory -Force;
    }

    $results = Invoke-Pester @pesterParams;

    # Throw an error if pester tests failed
    if ($Null -eq $results) {
        throw 'Failed to get Pester test results.';
    }
    elseif ($results.FailedCount -gt 0) {
        throw "$($results.FailedCount) tests failed.";
    }
}

# Synopsis: Run script analyzer
task Analyze Build, PSScriptAnalyzer, {
    Invoke-ScriptAnalyzer -Path out/modules/PSRule.Rules.Azure;
}

# Synopsis: Build table of content for rules
task BuildRuleDocs PSRule, PSDocs, {
    Invoke-PSDocument -Name Azure -OutputPath .\docs\rules\en-US\ -Path .\RuleToc.Document.ps1
}

# Synopsis: Build help
task BuildHelp BuildModule, PlatyPS, BuildRuleDocs, {
    # Generate MAML and about topics
    $Null = New-ExternalHelp -OutputPath out/docs/PSRule.Rules.Azure -Path '.\docs\commands\PSRule.Rules.Azure\en-US' -Force;

    # Copy generated help into module out path
    $Null = Copy-Item -Path out/docs/PSRule.Rules.Azure/ -Destination out/modules/PSRule.Rules.Azure/en-US/ -Recurse;
    $Null = Copy-Item -Path out/docs/PSRule.Rules.Azure/ -Destination out/modules/PSRule.Rules.Azure/en-AU/ -Recurse;
}

# Synopsis: Remove temp files.
task Clean {
    Remove-Item -Path out,reports -Recurse -Force -ErrorAction SilentlyContinue;
}

task Build Clean, BuildModule, VersionModule, BuildHelp

task Test Build, TestRules

task Release ReleaseModule

task . Build, Test
