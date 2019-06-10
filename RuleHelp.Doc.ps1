#
# Generate rule help
#

Document 'RuleHelp' {
    $tags = $InputObject.Tag;
    $rule = $InputObject.Info;
    Title $rule.Name

    $annotations = [ordered]@{}
    if ($Null -ne $rule.Annotations) {
        $annotations += $rule.Annotations;
    }
    elseif ($Null -ne $tags) {
        $annotations += $tags.ToHashTable();
    }

    if (!$annotations.Contains('online version')) {
        $annotations['online version'] = "https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/$($rule.Name).md";
    }

    Metadata $annotations;

    Section 'SYNOPSIS' -Force {
        if ($Null -ne $rule.Synopsis) {
            $rule.Synopsis;
        }
    }

    Section 'DESCRIPTION' -Force {
        if ($Null -ne $rule.Description) {
            $rule.Description;
        }
        elseif ($Null -ne $rule.Synopsis) {
            $rule.Synopsis;
        }
    }

    Section 'RECOMMENDATION' -Force {
        if ($Null -ne $rule.Recommendation) {
            $rule.Recommendation;
        }
        elseif ($Null -ne $rule.Synopsis) {
            $rule.Synopsis;
        }
    }

    Section 'NOTES' {
        $rule.Notes;
    }
}
