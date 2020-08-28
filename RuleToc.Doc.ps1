# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Document 'module' {
    Title 'Rules for architecture excellence'

    Import-Module .\out\modules\PSRule.Rules.Azure
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -WarningAction SilentlyContinue |
        Add-Member -MemberType ScriptProperty -Name Category -Value { $this.Info.Annotations.category } -PassThru |
        Add-Member -MemberType ScriptProperty -Name Pillar -Value { $this.Info.Annotations.pillar } -PassThru |
        Sort-Object -Property Pillar, Category;

    'PSRule for Azure includes the following rules across five pillars of the Microsoft Azure Well-Architected Framework.'

    $pillars = $rules | Group-Object -Property Pillar | Sort-Object -Property Name;

    foreach ($pillar in $pillars) {
        Section $pillar.Name {
            $categories = $pillar.Group | Group-Object -Property Category | Sort-Object -Property Name;

            foreach ($category in $categories) {
                Section $category.Name {
                    $category.Group |
                        Sort-Object -Property RuleName |
                        Table -Property @{ Name = 'Name'; Expression = {
                            "[$($_.RuleName)]($($_.RuleName).md)"
                        }}, Synopsis, @{ Name = 'Severity'; Expression = {
                            $_.Info.Annotations.severity
                        }}
                }
            }
        }
    }
}

Document 'resource' {
    Title 'Rules by resource'

    Import-Module .\out\modules\PSRule.Rules.Azure
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -WarningAction SilentlyContinue |
        Add-Member -MemberType ScriptProperty -Name Resource -Value { $this.Info.Annotations.resource } -PassThru |
        Sort-Object -Property Resource;

    Section 'Rules' {
        'The following rules are included within `PSRule.Rules.Azure`.'

        $resources = $rules | Group-Object -Property Resource;

        foreach ($resource in $resources) {
            Section "$($resource.Name)" {
                $resource.Group |
                    Sort-Object -Property RuleName |
                    Table -Property @{ Name = 'Name'; Expression = {
                        "[$($_.RuleName)]($($_.RuleName).md)"
                    }}, Synopsis, @{ Name = 'Severity'; Expression = {
                        $_.Info.Annotations.severity
                    }}
            }
        }
    }
}
