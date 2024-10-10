# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Imports in Bicep module paths for analysis.
Export-PSRuleConvention 'BicepModuleRequires.Import' -Initialize {
    # Find modules in the 'modules' directory and import them into PSRule as custom objects.
    $modules = @(Get-ChildItem -Path 'modules/' -Include 'main.bicep' -Recurse -File | ForEach-Object {
        $version = $_.Directory.Name
        $name = $_.Directory.Parent.Name
        [PSCustomObject]@{
            Name = $name
            Version = $version
            Path = $_.Directory.FullName
        }
    })
    $PSRule.ImportWithType('Azure.Bicep.ModuleInfo', $modules);
}

# Synopsis: A Bicep module must have a corresponding README file.
Rule 'BicepModuleRequires.RequireReadme' -Type 'Azure.Bicep.ModuleInfo' {
    $Assert.FilePath($TargetObject, 'Path', @('README.md'))
}

# Synopsis: A Bicep module must have a corresponding tests file.
Rule 'BicepModuleRequires.RequireTests' -Type 'Azure.Bicep.ModuleInfo' {
    $Assert.FilePath($TargetObject, 'Path', @('.tests/main.tests.bicep'))
}
