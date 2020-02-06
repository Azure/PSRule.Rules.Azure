# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validate templates
#

# Install PSRule.Rules.Azure module
if ($Null -eq (Get-InstalledModule -Name PSRule.Rules.Azure -MinimumVersion '0.6.0' -ErrorAction SilentlyContinue)) {
    $Null = Install-Module -Name PSRule.Rules.Azure -Scope CurrentUser -MinimumVersion '0.6.0' -Force;
}

# Resolve resources
Export-AzTemplateRuleData -TemplateFile .\template.json -ParameterFile .\parameters.json -OutputPath out/;

# Validate resources
$assertParams = @{
    InputPath = 'out/*.json'
    Module = 'PSRule.Rules.Azure'
    Style = 'AzurePipelines'
    OutputFormat = 'NUnit3'
    OutputPath = 'reports/rule-report.xml'
}
Assert-PSRule @assertParams;
