
Document 'Azure' {
    Title 'Azure rules'

    Metadata @{
        'generated-by' = 'PSDocs'
    }

    Get-PSRule -WarningAction SilentlyContinue | Table -Property RuleName, Description
}
