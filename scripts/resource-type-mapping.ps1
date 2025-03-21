# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# This script generates a JSON output of rules to resource types mapping.

$rules = (Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All | ForEach-Object {
    if ($_.Info.Annotations['resourceType'] -ne $null) {

        foreach ($resourceType in $_.Info.Annotations['resourceType'].Split(',')) {
            @{
                severity = $_.Info.Annotations['severity'];
                pillar = $_.Info.Annotations['pillar'];
                category = $_.Info.Annotations['category'];
                resourceType = $resourceType;
                ruleId = $_.Name;
            }
        }
    }
})

$rules | ConvertTo-Json -Depth 100 | Set-Content -Path data/resource-type-mapping.json
