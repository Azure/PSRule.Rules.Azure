# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Logic App
#

# Synopsis: Access IPs should be limited for HTTP triggers
Rule 'Azure.LogicApp.LimitHTTPTrigger' -Ref 'AZR-000130' -Type 'Microsoft.Logic/workflows' -If { LogicAppWithHttpTrigger } -Tag @{ release = 'GA'; ruleSet = '2020_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.accessControl.triggers.allowedCallerIpAddresses', 1);
}

#region Helper functions

function global:LogicAppWithHttpTrigger {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        if ($PSRule.TargetType -ne 'Microsoft.Logic/workflows' -or $Assert.NotHasField($TargetObject, 'Properties.definition.triggers').Result) {
            return $False;
        }
        $triggers = @($TargetObject.Properties.definition.triggers.PSObject.Properties.GetEnumerator() | ForEach-Object {
            $_.Value
        });
        foreach ($trigger in $triggers) {
            if ($trigger.Type -eq 'Request' -and $trigger.Kind -eq 'Http') {
                return $True;
            }
        }
        return $False;
    }
}

#endregion Helper functions
