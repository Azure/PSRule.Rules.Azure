# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Document 'index' {
    Title 'Reference'

    Metadata @{
        generated = $True
        title = 'Reference'
    }

    Import-Module ./out/modules/PSRule.Rules.Azure
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -WarningAction SilentlyContinue;

    'The following rules and features are included in PSRule for Azure.'

    @"
!!! Info
    The rule _release_ indicates if the Azure feature is _generally available (GA)_ or available under _preview_.
    Features provided under previews may have additional limits, availability restrictions, or [terms][1].
    By default, PSRule for Azure will not provide recommendations that relate to preview features.
    To include rules for preview features see [working with baselines][2].

  [1]: https://azure.microsoft.com/support/legal/preview-supplemental-terms/
  [2]: ../../working-with-baselines.md
"@

    Section 'Rules' {
        'The following rules are included in PSRule for Azure.'

        $rules | Sort-Object -Property Ref | Table -Property @{ Name = 'Reference'; Expression = {
            $_.Ref.Name
        }}, @{ Name = 'Name'; Expression = {
            "[$($_.RuleName)]($($_.RuleName).md)"
        }}, Synopsis, @{ Name = 'Release'; Expression = {
            if ($_.Tag.release -eq 'GA') {
                'GA'
            }
            else {
                'Preview'
            }
        }}
    }

    '*[GA]: Generally Available &mdash; Rules related to a generally available Azure features.'
}

Document 'module' {
    Title 'Rules by pillar'

    Metadata @{
        generated = $True
    }

    Import-Module ./out/modules/PSRule.Rules.Azure
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
                        }}, @{ Name = 'Level'; Expression = {
                            $_.Level.ToString()
                        }}
                }
            }
        }
    }
}

Document 'resource' {
    Title 'Rules by resource type'

    Metadata @{
        generated = $True
    }

    Import-Module ./out/modules/PSRule.Rules.Azure
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -WarningAction SilentlyContinue |
        Add-Member -MemberType ScriptProperty -Name Resource -Value { $this.Info.Annotations.resource } -PassThru |
        Sort-Object -Property Resource;

    'PSRule for Azure includes the following rules organized by resource type.'

    $resources = $rules | Group-Object -Property Resource;

    foreach ($resource in $resources) {
        Section "$($resource.Name)" {
            $resource.Group |
                Sort-Object -Property RuleName |
                Table -Property @{ Name = 'Name'; Expression = {
                    "[$($_.RuleName)]($($_.RuleName).md)"
                }}, Synopsis, @{ Name = 'Severity'; Expression = {
                    $_.Info.Annotations.severity
                }}, @{ Name = 'Level'; Expression = {
                    $_.Level.ToString()
                }}
        }
    }
}
