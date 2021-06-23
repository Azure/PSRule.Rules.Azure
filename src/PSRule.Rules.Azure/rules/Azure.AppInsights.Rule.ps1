# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Application Insights
#

# Synopsis: Configure Application Insights resources to store data in workspaces.
Rule 'Azure.AppInsights.Workspace' -Type 'microsoft.insights/components' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.WorkspaceResourceId');
}

# Synopsis: Azure Application Insights resources names should meet naming requirements.
Rule 'Azure.AppInsights.Name' -Type 'microsoft.insights/components' -Tag @{ release = 'GA'; ruleSet = '2021_06'; } {
    # Between 1 and 255 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1)
    $Assert.LessOrEqual($PSRule, 'TargetName', 255)

    # The name must contain between 1 to 255 characters inclusive.
    # The name only allows alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period.
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9.\-_()]{0,254}[a-z0-9\-_()]$')
}
