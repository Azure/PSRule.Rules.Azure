# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# This script generates a baselines that only includes rules that aligned to the security pillar.

$rules = @((Get-PSRule -Module PSRule.Rules.Azure | Where-Object { $_.Info.Annotations['pillar'] -eq 'Security' }).Id.Value);
$baseline = @(@{
    apiVersion = 'github.com/microsoft/PSRule/v1'
    kind = 'Baseline'
    metadata = @{
        name = 'SecurityBaseline'
    }
    spec = @{
        rule = @{
            include = @($rules)
        }
    }
})
ConvertTo-Json -Depth 100 -InputObject $baseline | Set-Content -Path .\Baseline.Rule.jsonc
