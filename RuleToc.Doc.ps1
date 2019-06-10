
Document 'Azure' {
    Title 'Azure rules'

    Metadata @{
        'generated-by' = 'PSDocs'
    }

    Get-PSRule -WarningAction SilentlyContinue | Table -Property @{ Name = 'RuleName'; Expression = {
        "[$($_.RuleName)]($($_.RuleName).md)"
    }}, Description
}
