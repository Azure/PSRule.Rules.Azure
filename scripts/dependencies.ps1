# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# Handles dependencies updates.

[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)]
    [String]$Path,

    [Parameter(Mandatory = $False)]
    [String]$Repository = 'PSGallery'
)

$modules = Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable;

$dependencies = [Ordered]@{ };
$modules.dependencies.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
    $dependencies[$_.Name] = $_.Value
}
foreach ($module in $dependencies.GetEnumerator()) {
    Write-Host -Object "[Dependencies] -- Checking $($module.Name)";
    $installParams = @{}
    $installParams += $module.Value;
    $installParams.MinimumVersion = $installParams.version;
    $installParams.Remove('version');
    $available = @(Find-Module -Repository $Repository -Name $module.Name @installParams -ErrorAction Ignore);
    foreach ($found in $available) {
        if (([Version]$found.Version) -gt ([Version]$module.Value.version)) {
            Write-Host -Object "[Dependencies] -- Newer version found $($found.Version)";
            $dependencies[$module.Name].version = $found.Version;
        }
        else {
            Write-Host -Object "[Dependencies] -- Already up to date.";
        }
    }
}

$devDependencies = [Ordered]@{ };
$modules.devDependencies.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
    $devDependencies[$_.Name] = $_.Value
}
foreach ($module in $devDependencies.GetEnumerator()) {
    Write-Host -Object "[DevDependencies] -- Checking $($module.Name)";
    $installParams = @{}
    $installParams += $module.Value;
    $installParams.MinimumVersion = $installParams.version;
    $installParams.Remove('version');
    $available = @(Find-Module -Repository $Repository -Name $module.Name @installParams -ErrorAction Ignore);
    foreach ($found in $available) {
        if (([Version]$found.Version) -gt ([Version]$module.Value.version)) {
            Write-Host -Object "[DevDependencies] -- Newer version found $($found.Version)";
            $devDependencies[$module.Name].version = $found.Version;
        }
        else {
            Write-Host -Object "[DevDependencies] -- Already up to date.";
        }
    }
}

$modules = [Ordered]@{
    dependencies = $dependencies
    devDependencies = $devDependencies
}
$modules | ConvertTo-Json -Depth 10 | Set-Content -Path $Path;

$updates = @(git status --porcelain)
if ($Null -ne $Env.WORKING_BRANCH -and $Null -ne $updates -and $updates.Length -gt 0) {
    git add modules.json
    git commit -m 'Update modules.json'
    git push origin $Env.WORKING_BRANCH
    gh pr create --base 'main' --head $Env.WORKING_BRANCH --title 'Bump PowerShell dependencies' --body '' --label 'dependencies'
}
