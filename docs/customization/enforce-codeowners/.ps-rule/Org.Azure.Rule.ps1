# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for validation of Azure Policy exemptions
#

# Synopsis: Policy exemptions must be stored under designated paths for review.
Rule 'Org.Azure.Policy.Path' -Type 'Microsoft.Authorization/policyExemptions' {
    $Assert.WithinPath($PSRule.Source['Parameter'], '.', @(
        'deployments/policy/'
    ));
}
