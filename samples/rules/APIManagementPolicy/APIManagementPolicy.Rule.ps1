# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Imports API Management policy XML files in for analysis.
Export-PSRuleConvention 'APIManagementPolicy.Import' -Initialize {
    $policies = @(Get-ChildItem -Path 'policies/' -Include '*.xml' -Recurse -File | ForEach-Object {
        $name = $_.Name
        [PSCustomObject]@{
            Name = $name
            Content = [Xml](Get-Content -Path $_.FullName -Raw)
        }
    })
    $PSRule.ImportWithType('Azure.APIM.PolicyContent', $policies)
}

# Synopsis: Checks that validate-jwt element exists in the policy.
Rule 'APIManagementPolicy.ValidateJwt' -Type 'Azure.APIM.PolicyContent' {
    $policy = @([Xml]$TargetObject.Content.SelectNodes('//validate-jwt'))

    # Check that validate-jwt is used in the policy.
    $Assert.Greater($policy, '.', 1)
}
