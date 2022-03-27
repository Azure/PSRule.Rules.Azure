# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [String]$Build = '0.0.1',

    [Parameter(Mandatory = $False)]
    [String]$Configuration = 'Debug',

    [Parameter(Mandatory = $False)]
    [String]$ApiKey,

    [Parameter(Mandatory = $False)]
    [Switch]$CodeCoverage = $False,

    [Parameter(Mandatory = $False)]
    [Switch]$Benchmark = $False,

    [Parameter(Mandatory = $False)]
    [String]$ArtifactPath = (Join-Path -Path $PWD -ChildPath out/modules),

    [Parameter(Mandatory = $False)]
    [String]$AssertStyle = 'AzurePipelines',

    [Parameter(Mandatory = $False)]
    [String]$TestGroup = $Null
)

Write-Host -Object "[Pipeline] -- PowerShell: v$($PSVersionTable.PSVersion.ToString())" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- PWD: $PWD" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- ArtifactPath: $ArtifactPath" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- BuildNumber: $($Env:BUILD_BUILDNUMBER)" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- SourceBranch: $($Env:BUILD_SOURCEBRANCH)" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- SourceBranchName: $($Env:BUILD_SOURCEBRANCHNAME)" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- Culture: $((Get-Culture).Name), $((Get-Culture).Parent)" -ForegroundColor Green;

if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue';
}

$forcePublish = $False;
if ($Env:FORCE_PUBLISH -eq 'true') {
    $forcePublish = $True;
}

if ($Env:BUILD_SOURCEBRANCH -like '*/tags/*' -and $Env:BUILD_SOURCEBRANCHNAME -like 'v1.*') {
    $Build = $Env:BUILD_SOURCEBRANCHNAME.Substring(1);
}

$version = $Build;
$versionSuffix = [String]::Empty;

if ($version -like '*-*') {
    [String[]]$versionParts = $version.Split('-', [System.StringSplitOptions]::RemoveEmptyEntries);
    $version = $versionParts[0];

    if ($versionParts.Length -eq 2) {
        $versionSuffix = $versionParts[1];
    }
}

Write-Host -Object "[Pipeline] -- Using version: $version" -ForegroundColor Green;
Write-Host -Object "[Pipeline] -- Using versionSuffix: $versionSuffix" -ForegroundColor Green;

if ($Env:COVERAGE -eq 'true') {
    $CodeCoverage = $True;
}

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

        Get-ChildItem -Path $sourcePath -Recurse -File -Include *.ps1, *.psm1, *.psd1, *.ps1xml, *.yaml | Where-Object -FilterScript {
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

task VersionModule ModuleDependencies, {
    $modulePath = Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure;
    $manifestPath = Join-Path -Path $modulePath -ChildPath PSRule.Rules.Azure.psd1;
    Write-Verbose -Message "[VersionModule] -- Checking module path: $modulePath";

    if (![String]::IsNullOrEmpty($Build)) {
        # Update module version
        if (![String]::IsNullOrEmpty($version)) {
            Write-Verbose -Message "[VersionModule] -- Updating module manifest ModuleVersion";
            Update-ModuleManifest -Path $manifestPath -ModuleVersion $version;
        }

        # Update pre-release version
        if (![String]::IsNullOrEmpty($versionSuffix)) {
            Write-Verbose -Message "[VersionModule] -- Updating module manifest Prerelease";
            Update-ModuleManifest -Path $manifestPath -Prerelease $versionSuffix;
        }
    }

    $dependencies = Get-Content -Path $PWD/modules.json -Raw | ConvertFrom-Json;
    $manifest = Test-ModuleManifest -Path $manifestPath;
    $requiredModules = $manifest.RequiredModules | ForEach-Object -Process {
        if ($_.Name -eq 'PSRule' -and $Configuration -eq 'Release') {
            @{ ModuleName = 'PSRule'; ModuleVersion = $dependencies.dependencies.PSRule.version }
        }
        else {
            @{ ModuleName = $_.Name; ModuleVersion = $_.Version }
        }
    };
    Update-ModuleManifest -Path $manifestPath -RequiredModules $requiredModules;
}

# Synopsis: Publish to PowerShell Gallery
task ReleaseModule VersionModule, {
    $modulePath = (Join-Path -Path $ArtifactPath -ChildPath PSRule.Rules.Azure);
    Write-Verbose -Message "[ReleaseModule] -- Checking module path: $modulePath";

    if (!(Test-Path -Path $modulePath)) {
        Write-Error -Message "[ReleaseModule] -- Module path does not exist";
    }
    elseif (![String]::IsNullOrEmpty($ApiKey)) {
        Publish-Module -Path $modulePath -NuGetApiKey $ApiKey -Force:$forcePublish;
    }
}

# Synopsis: Install NuGet provider
task NuGet {
    if ($Null -eq (Get-PackageProvider -Name NuGet -ErrorAction Ignore)) {
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
    }
}

# Synopsis: Install module dependencies
task ModuleDependencies Dependencies, {
    if ($Null -eq (Get-InstalledModule -Name Az.Accounts -MinimumVersion 2.5.2 -ErrorAction Ignore)) {
        Install-Module -Name Az.Accounts -Scope CurrentUser -MinimumVersion 2.5.2 -Force;
    }
    if ($Null -eq (Get-InstalledModule -Name Az.Resources -MinimumVersion 4.3.0 -ErrorAction Ignore)) {
        Install-Module -Name Az.Resources -Scope CurrentUser -MinimumVersion 4.3.0 -Force;
    }
}

task BuildDotNet {
    exec {
        # Build library
        dotnet publish src/PSRule.Rules.Azure -c $Configuration -f netstandard2.0 -o $(Join-Path -Path $PWD -ChildPath out/modules/PSRule.Rules.Azure) -p:version=$Build
    }
}

task TestDotNet {
    if ($CodeCoverage) {
        exec {
            # Test library
            dotnet test --collect:"Code Coverage" --logger trx -r (Join-Path $PWD -ChildPath reports/) tests/PSRule.Rules.Azure.Tests
        }
    }
    else {
        exec {
            # Test library
            dotnet test --logger trx -r (Join-Path $PWD -ChildPath reports/) tests/PSRule.Rules.Azure.Tests
        }
    }
}

task MinifyData {
    $dataPath = Join-Path -Path $PWD -ChildPath 'data';
    $dataOutPath = Join-Path -Path $PWD -ChildPath 'out/data';
    if (!(Test-Path -Path $dataOutPath)) {
        $Null = New-Item -Path $dataOutPath -ItemType Directory -Force;
    }

    foreach ($dataFile in 'providers.json', 'environments.json', 'aliases.json') {
        $filePath = Join-Path -Path $dataPath -ChildPath $dataFile;
        $fileOutPath = Join-Path -Path $dataOutPath -ChildPath $dataFile;
        Get-Content -Path $filePath -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress | Set-Content -Path $fileOutPath;
    }
}

task CopyModule MinifyData, {
    CopyModuleFiles -Path src/PSRule.Rules.Azure -DestinationPath out/modules/PSRule.Rules.Azure;

    # Copy LICENSE
    Copy-Item -Path LICENSE -Destination out/modules/PSRule.Rules.Azure;

    # Copy third party notices
    Copy-Item -Path ThirdPartyNotices.txt -Destination out/modules/PSRule.Rules.Azure;

    # Copy data
    Copy-Item -Path 'out/data/*.json' -Destination out/modules/PSRule.Rules.Azure -Recurse;
}

# Synopsis: Build modules only
task BuildModule BuildDotNet, CopyModule

task TestModule ModuleDependencies, BicepIntegrationTests, {
    # Run Pester tests
    $pesterOptions = @{
        Run        = @{
            Path     = (Join-Path -Path $PWD -ChildPath tests/PSRule.Rules.Azure.Tests);
            PassThru = $True;
        };
        TestResult = @{
            Enabled      = $True;
            OutputFormat = 'NUnitXml';
            OutputPath   = 'reports/pester-unit.xml';
        };
    };

    if ($CodeCoverage) {
        $codeCoverageOptions = @{
            Enabled    = $True;
            OutputPath = (Join-Path -Path $PWD -ChildPath 'reports/pester-coverage.xml');
            Path       = (Join-Path -Path $PWD -ChildPath 'out/modules/**/*.psm1');
        };

        $pesterOptions.Add('CodeCoverage', $codeCoverageOptions);
    }

    if (!(Test-Path -Path reports)) {
        $Null = New-Item -Path reports -ItemType Directory -Force;
    }

    if ($Null -ne $TestGroup) {
        $pesterOptions.Add('Filter', @{ Tag = $TestGroup });
    }

    # https://pester.dev/docs/commands/New-PesterConfiguration
    $pesterConfiguration = New-PesterConfiguration -Hashtable $pesterOptions;

    $results = Invoke-Pester -Configuration $pesterConfiguration;

    # Throw an error if pester tests failed
    if ($Null -eq $results) {
        throw 'Failed to get Pester test results.';
    }
    elseif ($results.FailedCount -gt 0) {
        throw "$($results.FailedCount) tests failed.";
    }
}

task IntegrationTest ModuleDependencies, {
    # Run Pester tests
    $pesterOptions = @{
        Run        = @{
            Path     = (Join-Path -Path $PWD -ChildPath tests/Integration);
            PassThru = $True;
        };
        TestResult = @{
            Enabled      = $True;
            OutputFormat = 'NUnitXml';
            OutputPath   = 'reports/pester-unit.xml';
        };
    };

    if (!(Test-Path -Path reports)) {
        $Null = New-Item -Path reports -ItemType Directory -Force;
    }

    # https://pester.dev/docs/commands/New-PesterConfiguration
    $pesterConfiguration = New-PesterConfiguration -Hashtable $pesterOptions;

    $results = Invoke-Pester -Configuration $pesterConfiguration

    # Throw an error if pester tests failed
    if ($Null -eq $results) {
        throw 'Failed to get Pester test results.';
    }
    elseif ($results.FailedCount -gt 0) {
        throw "$($results.FailedCount) tests failed.";
    }
}

task BicepIntegrationTests {
    if ($Env:RUN_BICEP_INTEGRATION -eq 'true') {
        # Run Pester tests
        $pesterOptions = @{
            Run        = @{
                Path     = (Join-Path -Path $PWD -ChildPath tests/Bicep);
                PassThru = $True;
            };
            TestResult = @{
                Enabled      = $True;
                OutputFormat = 'NUnitXml';
                OutputPath   = 'reports/bicep-integration.xml';
            };
        };

        if (!(Test-Path -Path reports)) {
            $Null = New-Item -Path reports -ItemType Directory -Force;
        }

        # https://pester.dev/docs/commands/New-PesterConfiguration
        $pesterConfiguration = New-PesterConfiguration -Hashtable $pesterOptions;

        $results = Invoke-Pester -Configuration $pesterConfiguration;

        # Throw an error if pester tests failed
        if ($Null -eq $results) {
            throw 'Failed to get Pester test results.';
        }
        elseif ($results.FailedCount -gt 0) {
            throw "$($results.FailedCount) tests failed.";
        }
    }
}

# Synopsis: Run validation
task Rules Dependencies, {
    $assertParams = @{
        Path         = './.ps-rule/'
        Style        = $AssertStyle
        OutputFormat = 'NUnit3'
        ErrorAction  = 'Stop'
        As           = 'Summary'
    }
    Import-Module (Join-Path -Path $PWD -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    Assert-PSRule @assertParams -InputPath $PWD -Module PSRule.Rules.MSFT.OSS -Format File -OutputPath reports/ps-rule-file.xml;

    $rules = Get-PSRule -Module PSRule.Rules.Azure;
    $rules | Assert-PSRule @assertParams -OutputPath reports/ps-rule-file2.xml;
}

# Synopsis: Run script analyzer
task Analyze Build, Dependencies, {
    Invoke-ScriptAnalyzer -Path out/modules/PSRule.Rules.Azure;
}

# Synopsis: Build documentation
task BuildDocs BuildRuleDocs, BuildBaselineDocs

# Synopsis: Build table of content for rules
task BuildRuleDocs Build, Dependencies, {
    Import-Module (Join-Path -Path $PWD -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    $Null = './out/modules/PSRule.Rules.Azure' | Invoke-PSDocument -Name module -OutputPath ./docs/en/rules/ -Path ./RuleToc.Doc.ps1;
    $Null = './out/modules/PSRule.Rules.Azure' | Invoke-PSDocument -Name resource -OutputPath ./docs/en/rules/ -Path ./RuleToc.Doc.ps1;
}

# Synopsis: Build table of content for baselines
task BuildBaselineDocs Build, Dependencies, {
    Import-Module (Join-Path -Path $PWD -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    $baselines = Get-PSRuleBaseline -Module PSRule.Rules.Azure -WarningAction SilentlyContinue;
    $baselines | ForEach-Object {
        $baselineDoc = [PSCustomObject]@{
            Name     = $_.Name
            Metadata = $_.Metadata
            Synopsis = $_.Synopsis
            Rules    = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline $_.Name -WarningAction SilentlyContinue)
        }
        $baselineDoc;
    } | Invoke-PSDocument -Name baseline -OutputPath ./docs/en/baselines/ -Path ./BaselineToc.Doc.ps1 -Convention 'NameBaseline';
}

# Synopsis: Build help
task BuildHelp BuildModule, Dependencies, {
    if (!(Test-Path out/modules/PSRule.Rules.Azure/en/)) {
        $Null = New-Item -Path out/modules/PSRule.Rules.Azure/en/ -ItemType Directory -Force;
    }
    if (!(Test-Path out/modules/PSRule.Rules.Azure/en-US/)) {
        $Null = New-Item -Path out/modules/PSRule.Rules.Azure/en-US/ -ItemType Directory -Force;
    }
    if (!(Test-Path out/modules/PSRule.Rules.Azure/en-AU/)) {
        $Null = New-Item -Path out/modules/PSRule.Rules.Azure/en-AU/ -ItemType Directory -Force;
    }
    if (!(Test-Path out/modules/PSRule.Rules.Azure/en-GB/)) {
        $Null = New-Item -Path out/modules/PSRule.Rules.Azure/en-GB/ -ItemType Directory -Force;
    }

    $Null = Copy-Item -Path docs/en/rules/*.md -Destination out/modules/PSRule.Rules.Azure/en/;

    # Avoid YamlDotNet issue in same app domain
    exec {
        $pwshPath = (Get-Process -Id $PID).Path;
        &$pwshPath -Command {
            # Generate MAML and about topics
            Import-Module -Name PlatyPS -Verbose:$False;
            $Null = New-ExternalHelp -OutputPath 'out/docs/PSRule.Rules.Azure' -Path './docs/commands', './docs/concepts' -Force;

            # Copy generated help into module out path
            $Null = Copy-Item -Path out/docs/PSRule.Rules.Azure/* -Destination out/modules/PSRule.Rules.Azure/en-US/ -Recurse;
            $Null = Copy-Item -Path out/docs/PSRule.Rules.Azure/* -Destination out/modules/PSRule.Rules.Azure/en-AU/ -Recurse;
            $Null = Copy-Item -Path out/docs/PSRule.Rules.Azure/* -Destination out/modules/PSRule.Rules.Azure/en-GB/ -Recurse;
        }
    }

    if (!(Test-Path -Path 'out/docs/PSRule.Rules.Azure/PSRule.Rules.Azure-help.xml')) {
        throw 'Failed find generated cmdlet help.';
    }
}

task ScaffoldHelp Build, BuildRuleDocs, {
    Import-Module (Join-Path -Path $PWD -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    Update-MarkdownHelp -Path '.\docs\commands';
}

task Benchmark {
    if ($Benchmark -or $BuildTask -eq 'Benchmark') {
        dotnet run -p src/PSRule.Rules.Azure.Benchmark -f netcoreapp3.1 -c Release -- benchmark --output $PWD;
    }
}

task Dependencies NuGet, {
    Import-Module $PWD/scripts/dependencies.psm1;
    Install-Dependencies -Path $PWD/modules.json;
}

task ExportAliases {
    $index = [ordered]@{};

    Get-AzPolicyAlias | Sort-Object -Property Namespace | ForEach-Object {
        $namespace = $_.Namespace;

        if (!($index.Contains($namespace))) {
            $index.Add($namespace, [ordered]@{});
        }

        $aliasMappings = [ordered]@{};
        $_.Aliases | Sort-Object -Property Name | ForEach-Object {
            $aliasMappings.Add($_.Name, $_.DefaultPath);
        }

        $info = [ordered]@{
            locations     = $_.Locations | Sort-Object
            aliasMappings = $aliasMappings
            apiVersions   = $_.ApiVersions | Sort-Object
        }

        $index[$namespace].Add($_.ResourceType, $info);
    }

    $dataPath = Join-Path -Path $PWD -ChildPath 'data';
    if (!(Test-Path -Path $dataPath)) {
        $Null = New-Item -Path $dataPath -ItemType Directory -Force;
    }
    $index | ConvertTo-Json -Depth 20 | Set-Content ./data/aliases.json;
}

task ExportProviders {
    $subscriptionId = (Get-AzContext).Subscription.Id
    $providers = @(((Invoke-AzRest -Method Get -Path "/subscriptions/$subscriptionId/providers?api-version=2021-04-01").Content | ConvertFrom-Json).value | Sort-Object -Property namespace -CaseSensitive)
    $index = [ordered]@{}
    foreach ($provider in $providers) {
        $namespace = $provider.namespace;
        $resourceTypes = [ordered]@{};
        $provider.resourceTypes | Sort-Object -Property resourceType | ForEach-Object {
            $info = [ordered]@{
                resourceType = $_.resourceType
                apiVersions  = $_.apiVersions
                locations    = $_.locations
                zoneMappings = ($_.ZoneMappings | Sort-Object -Property location | ForEach-Object {
                        $zones = $_.zones
                        if ($Null -ne $zones) {
                            $zones = @($_.zones | Sort-Object)
                        }
                        [ordered]@{
                            location = $_.location
                            zones    = $zones
                        }
                    })
            }
            $resourceTypes.Add($info.resourceType, $info);
        };
        $entry = [ordered]@{
            types = $resourceTypes
        }
        $index.Add($namespace, $entry);
    }

    $dataPath = Join-Path -Path $PWD -ChildPath 'data';
    if (!(Test-Path -Path $dataPath)) {
        $Null = New-Item -Path $dataPath -ItemType Directory -Force;
    }
    $index | ConvertTo-Json -Depth 20 | Set-Content ./data/providers.json;
}

task ExportData ExportProviders

# Synopsis: Add shipit build tag
task TagBuild {
    if ($Null -ne $Env:BUILD_DEFINITIONNAME) {
        Write-Host "`#`#vso[build.addbuildtag]shipit";
    }
}

# Synopsis: Remove temp files.
task Clean {
    dotnet clean;
    Remove-Item -Path out, reports -Recurse -Force -ErrorAction SilentlyContinue;
}

task Build Clean, BuildModule, VersionModule, BuildHelp

task Test Build, Rules, TestDotNet, TestModule

task Release ReleaseModule, TagBuild

# Synopsis: Build and test. Entry point for CI Build stage
task . Build, Rules, TestDotNet
