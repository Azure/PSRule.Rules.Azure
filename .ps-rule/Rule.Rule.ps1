# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Use short rule names
Rule 'Rule.Name' -Type 'PSRule.Rules.Rule' {
    Recommend 'Rule name should be less than 35 characters to prevent being truncated.'
    Reason 'The rule name is too long.'
    $Assert.LessOrEqual($TargetObject, 'RuleName', 35)
    $Assert.StartsWith($TargetObject, 'RuleName', 'Azure.')
}

# Synopsis: Complete help documentation
Rule 'Rule.Help' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Synopsis')
    $Assert.HasFieldValue($TargetObject, 'Info.Description')
    $Assert.HasFieldValue($TargetObject, 'Info.Recommendation')
}

# Synopsis: Rules must flag if the Azure feature is GA or preview
Rule 'Rule.Release' -Type 'PSRule.Rules.Rule' {
    Recommend 'Add a release tag to the rule.'
    $TargetObject.Tag.ToHashtable() | Within 'release' 'GA', 'preview' -CaseSensitive
}

# Synopsis: Rules must be added to a rule set
Rule 'Rule.RuleSet' -Type 'PSRule.Rules.Rule' {
    Recommend 'Add a ruleSet the to the rule.'
    $TargetObject.Tag.ToHashtable() | Exists 'ruleSet'
}

# Synopsis: Use severity and category annotations
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

# Synopsis: Use severity and category annotations
Rule 'Rule.Annotations' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.severity')
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.category')
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.resource')
}

# Synopsis: Use online help
Rule 'Rule.OnlineHelp' -Type 'PSRule.Rules.Rule' {
    $Assert.HasFieldValue($TargetObject, 'Info.Annotations.''online version''')
}
