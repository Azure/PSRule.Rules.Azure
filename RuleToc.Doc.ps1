
Document 'module' {
    Title 'Module rule reference'

    Import-Module .\out\modules\PSRule.Rules.Azure
    $rules = Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -WarningAction SilentlyContinue |
        Add-Member -MemberType ScriptProperty -Name Category -Value { $this.Info.Annotations.category } -PassThru |
        Sort-Object -Property Category;

    Section 'Baselines' {
        # 'The following baselines are included within `PSRule.Rules.Azure`.'
    }

    Section 'Rules' {
        'The following rules are included within `PSRule.Rules.Azure`.'

        $categories = $rules | Group-Object -Property Category;

        foreach ($category in $categories) {
            Section "$($category.Name)" {
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
