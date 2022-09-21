# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Use short rule names.
Rule 'Rule.Name' -Type 'PSRule.Rules.Rule' {
    Recommend 'Rule name should be less than 35 characters to prevent being truncated.'
    Reason 'The rule name is too long.'
    $Assert.LessOrEqual($TargetObject, 'RuleName', 35)
    $Assert.StartsWith($TargetObject, 'RuleName', 'Azure.')
}

# Synopsis: Rules must use a valid opaque identifier.
Rule 'Rule.Ref' -Type 'PSRule.Rules.Rule' {
    $Assert.Match($TargetObject, 'Ref.Name', '^AZR-[0-9]{6,6}$', $True)
}

# Synopsis: Complete help documentation.
Rule 'Rule.Help' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Synopsis')
    $Assert.HasFieldValue($TargetObject, 'Info.Description')
    $Assert.HasFieldValue($TargetObject, 'Info.Recommendation')
}

# Synopsis: Rules must flag if the Azure feature is GA or preview.
Rule 'Rule.Release' -Type 'PSRule.Rules.Rule' {
    Recommend 'Add a release tag to the rule.'
    $Assert.In($TargetObject, 'Tag.release', @('GA', 'preview'), $True)
}

# Synopsis: Rules must be added to a rule set.
Rule 'Rule.RuleSet' -Type 'PSRule.Rules.Rule' {
    Recommend 'Add a ruleSet the to the rule.'
    $Assert.HasField($TargetObject, 'Tag.ruleSet', $True)
}

# Synopsis: Annotate rules with a valid Well-Architected Framework pillar.
Rule 'Rule.Pillar' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.pillar')
    $Assert.In($TargetObject, 'Info.Annotations.pillar', @(
        'Cost Optimization'
        'Operational Excellence'
        'Performance Efficiency'
        'Reliability'
        'Security'
    ))
}

# Synopsis: Use severity, category, and resource annotations.
Rule 'Rule.Annotations' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.severity')
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.category')
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.resource')
}

# Synopsis: Configure a link for online rule help.
Rule 'Rule.OnlineHelp' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.''online version''')
    $Assert.StartsWith($TargetObject, 'Info.Annotations.''online version''', 'https://azure.github.io/PSRule.Rules.Azure/')
    $Assert.EndsWith($TargetObject, 'Info.Annotations.''online version''', [String]::Concat('/rules/', $TargetObject.RuleName, '/'))
}

# Synopsis: Use non-culture specific URLs for references to docs.microsoft.com.
Rule 'Rule.NonCultureMSDocs' -Type 'PSRule.Rules.Rule' -If { $Assert.Greater($TargetObject, 'Info.Links', 0) } {
    $links = @($TargetObject.Info.Links)
    if ($links.Length -eq 0) {
        return $Assert.Pass()
    }
    foreach ($link in $links) {
        $Assert.NotMatch($link, 'Uri', 'https\:\/\/docs\.microsoft\.com\/[a-z]{2,2}-[a-z]{2,2}\/\w{1,}')
        $Assert.NotMatch($link, 'Uri', 'https\:\/\/learn\.microsoft\.com\/[a-z]{2,2}-[a-z]{2,2}\/\w{1,}')
    }
}
