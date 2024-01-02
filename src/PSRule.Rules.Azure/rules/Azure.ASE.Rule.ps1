# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure App Service Environment
#

# Synopsis: Use ASEv3 as replacement for the classic app service environment versions ASEv1 and ASEv2.
Rule 'Azure.ASE.MigrateV3' -Ref 'AZR-000319' -Type 'Microsoft.Web/hostingEnvironments' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.HasFieldValue($TargetObject, 'kind', 'ASEV3').Reason($LocalizedData.ClassicASEDeprecated, $PSRule.TargetName, $TargetObject.kind)
}
