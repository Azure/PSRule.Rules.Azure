
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Document 'index' {
    Title 'Baselines'

    Metadata @{
        generated = $True
        title = 'Baselines'
    }

    Import-Module ./out/modules/PSRule.Rules.Azure
    $baselines = Get-PSRuleBaseline -Module PSRule.Rules.Azure -WarningAction SilentlyContinue;

    Section 'Quarterly baselines' {
        'Quarterly baselines provide a quarterly checkpoint of rules.'

        Section 'GA' {
            'The following baselines relate to generally available Azure features.'

            $baselines | Where-Object { $_.Name -like 'Azure.GA_*' } | Sort-Object -Property Name -Descending | Table -Property @{ Name = 'Name'; Expression = {
                "[$($_.Name)]($($_.Name).md)"
            }}, Synopsis, @{ Name = 'Status'; Expression = {
                if ($_.Flags -eq 'None') {
                    'Latest'
                }
                else {
                    $_.Flags.ToString()
                }
            }}

        }

        Section 'Preview' {
            'The following baselines relate to preview Azure features.'

            $baselines | Where-Object { $_.Name -like 'Azure.Preview_*' } | Sort-Object -Property Name -Descending | Table -Property @{ Name = 'Name'; Expression = {
                "[$($_.Name)]($($_.Name).md)"
            }}, Synopsis, @{ Name = 'Status'; Expression = {
                if ($_.Flags -eq 'None') {
                    'Latest'
                }
                else {
                    $_.Flags.ToString()
                }
            }}
        }
    }

    Section 'Pillar specific baselines' {
        'Pillar specific baselines provide a focused set of rules for a specific Azure Well-Architected Pillar.'

        $baselines | Where-Object { $_.Name -like 'Azure.Pillar.*' } | Sort-Object -Property Name -Descending | Table -Property @{ Name = 'Name'; Expression = {
            "[$($_.Name)]($($_.Name).md)"
        }}, Synopsis, @{ Name = 'Status'; Expression = {
            if ($_.Flags -eq 'None') {
                'Latest'
            }
            else {
                $_.Flags.ToString()
            }
        }}
    }
}
