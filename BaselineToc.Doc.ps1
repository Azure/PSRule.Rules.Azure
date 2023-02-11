# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Export-PSDocumentConvention 'NameBaseline' -Process {
    $PSDocs.Document.InstanceName = $PSDocs.TargetObject.Name;
}

Document 'baseline' -If { $PSDocs.TargetObject.Name -ne 'Azure.MCSB.v1' } {
    $baselineName = $PSDocs.TargetObject.Name;
    $obsolete = $PSDocs.TargetObject.metadata.annotations.obsolete -eq $True;

    Write-Verbose -Message "[Baseline] -- Processing baseline: $baselineName";
    Write-Verbose -Message "[Baseline] -- Baseline is obsolete: $obsolete";

    Title $baselineName;

    if ($obsolete) {
        '<!-- OBSOLETE -->'
    }

    $rules = $PSDocs.TargetObject.Rules | Sort-Object -Property RuleName;
    $ruleCount = $rules.Length;

    $PSDocs.TargetObject.Synopsis;

    Write-Verbose -Message "[Baseline] -- Found $ruleCount rules.";

    Section 'Rules' -If { $ruleCount -gt 0 } {
        "The following rules are included within ``$baselineName``. This baseline includes a total of $ruleCount rules.";
        $rules | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.RuleName)](../rules/$($_.RuleName).md)"
        }}, Synopsis, @{ Name = 'Severity'; Expression = {
            $_.Info.Annotations.severity
        }}
    }
}

Document 'asb.baseline' -If { $PSDocs.TargetObject.Name -eq 'Azure.MCSB.v1' } {
    $baselineName = $PSDocs.TargetObject.Name;
    $obsolete = $PSDocs.TargetObject.metadata.annotations.obsolete -eq $True;

    Write-Verbose -Message "[Baseline] -- Processing baseline: $baselineName";
    Write-Verbose -Message "[Baseline] -- Baseline is obsolete: $obsolete";

    Title $baselineName;

    if ($obsolete) {
        '<!-- OBSOLETE -->'
    }

    $rules = $PSDocs.TargetObject.Rules | Sort-Object -Property RuleName;
    $ruleCount = $rules.Length;

    $PSDocs.TargetObject.Synopsis;

    Write-Verbose -Message "[Baseline] -- Found $ruleCount rules.";

    Section 'Controls' -If { $ruleCount -gt 0 } {
        "The following rules are included within ``$baselineName``. This baseline includes a total of $ruleCount rules.";
        $rules | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.RuleName)](../rules/$($_.RuleName).md)"
        }}, Synopsis, @{ Name = 'Severity'; Expression = {
            $_.Info.Annotations.severity
        }}
    }
}
