# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure deployments
#

#region Rules

# Synopsis: Avoid outputting sensitive deployment values.
Rule 'Azure.Deployment.OutputSecretValue' -Ref 'AZR-000279' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_06'; } {
    $Assert.Create($PSRule.Issue.Get('PSRule.Rules.Azure.Template.OutputSecretValue'));
}

#endregion Rules
