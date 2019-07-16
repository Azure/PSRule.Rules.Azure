
Document 'Azure' {
    Title 'Azure rules'

    Import-Module .\out\modules\PSRule.Rules.Azure
    Get-PSRule -Module PSRule.Rules.Azure -WarningAction SilentlyContinue | Table -Property @{ Name = 'RuleName'; Expression = {
        "[$($_.RuleName)]($($_.RuleName).md)"
    }}, Description, @{ Name = 'Category'; Expression = {
        $_.Info.Annotations.category
    }}
}
