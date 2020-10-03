# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Document 'baseline' {
    $baselineName = $InputObject.Name;
    $obsolete = $InputObject.metadata.annotations.obsolete -eq $True;

    Title $baselineName;

    if ($obsolete) {
        'Obsolete' | BlockQuote
    }

    Import-Module .\out\modules\PSRule.Rules.Azure;
    $rules = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline $baselineName -WarningAction SilentlyContinue);
    $ruleCount = $rules.Length;

    $InputObject.Synopsis;

    Section 'Rules' {
        "The following rules are included within ``$baselineName``. This baseline includes a total of $ruleCount rules."

        $rules | Sort-Object -Property RuleName | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.RuleName)]($($_.RuleName).md)"
        }}, Synopsis, @{ Name = 'Severity'; Expression = {
            $_.Info.Annotations.severity
        }}
    }
}
