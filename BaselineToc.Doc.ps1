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

    $rules = $PSDocs.TargetObject.Rules | Sort-Object -Property Name;
    $ruleCount = $rules.Length;

    $PSDocs.TargetObject.Synopsis;

    Write-Verbose -Message "[Baseline] -- Found $ruleCount rules.";

    Section 'Rules' -If { $ruleCount -gt 0 } {
        "The following rules are included within ``$baselineName``. This baseline includes a total of $ruleCount rules.";
        $rules | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.Name)](../rules/$($_.Name).md)"
        }}, Synopsis, @{ Name = 'Severity'; Expression = {
            $_.Info.Annotations.severity
        }}
    }
}

Document 'Azure.MCSB.Baseline' -If { $PSDocs.TargetObject.Name -eq 'Azure.MCSB.v1' } {
    $baselineName = $PSDocs.TargetObject.Name;
    $obsolete = $PSDocs.TargetObject.metadata.annotations.obsolete -eq $True;
    $experimental = $PSDocs.TargetObject.metadata.annotations.experimental -eq $True;

    Write-Verbose -Message "[Baseline] -- Processing baseline: $baselineName";
    Write-Verbose -Message "[Baseline] -- Baseline is obsolete: $obsolete";
    Write-Verbose -Message "[Baseline] -- Baseline is experimental: $experimental";

    Title $baselineName;

    if ($experimental) {
        '<!-- EXPERIMENTAL -->'
    }

    if ($obsolete) {
        '<!-- OBSOLETE -->'
    }

    $rules = $PSDocs.TargetObject.Rules | Sort-Object -Property Name;
    $ruleCount = $rules.Length;

    $PSDocs.TargetObject.Synopsis;

    Write-Verbose -Message "[Baseline] -- Found $ruleCount rules.";

    Section 'Controls' -If { $ruleCount -gt 0 } {
        "The following rules are included within ``$baselineName``. This baseline includes a total of $ruleCount rules.";
        $rules | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.Name)](../rules/$($_.Name).md)"
        }}, Synopsis, @{ Name = 'Severity'; Expression = {
            $_.Info.Annotations.severity
        }}
    }
}
